import Dispatch
import Foundation

import KituraWebSocket
import LoggerAPI
import MongoKitten
import KituraKafka

public class DemoConsumeSocket: WebSocketService {
    
    private var messageController: MessageController?
    private static var MONGO_CONNECTOR: MongoConnector? = try? MongoConnector()
    public init() {}
    
    var currentConnection: WebSocketConnection?
    let connectionSemaphore = DispatchSemaphore(value: 1)

    public func connected(connection: WebSocketConnection) {
        Log.debug("Socket opened with id \(connection.id)")
        connectionSemaphore.wait()
        self.currentConnection = connection
        connectionSemaphore.signal()
    }
    
    /// Called when a WebSocket client disconnects from the server.
    ///
    /// - Parameter connection: The `WebSocketConnection` object that represents the connection that
    ///                    was disconnected from this `WebSocketService`.
    /// - Paramater reason: The `WebSocketCloseReasonCode` that describes why the client disconnected.
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        Log.debug("Closed websocket")
        if let controller = messageController {
            connectionSemaphore.wait()
            if connection.id == currentConnection?.id {
                Log.debug("Stopping message controller")
                controller.exit = true
            }
            connectionSemaphore.signal()
        }
        Log.info("Consumer and client connection for session \(connection.id) closed.")
    }
    
    /// Called when a WebSocket client sent a binary message to the server to this `WebSocketService`.
    ///
    /// - Parameter message: A Data struct containing the bytes of the binary message sent by the client.
    /// - Parameter client: The `WebSocketConnection` object that represents the connection over which
    ///                    the client sent the message to this `WebSocketService`
    public func received(message: Data, from: WebSocketConnection) {}

    public func received(message: String, from: WebSocketConnection) {
        guard message.count > 1 else { return }
        Log.debug("Message received from session: \(from.id) with action: \(message)")
        if message.contains("start") {
            if messageController == nil {
                Log.debug("Starting message consumption: \(message)")
                messageController = MessageController(demoConsumeSocket: self)
                messageController?.start()
            } else {
                if messageController?.sendMessages == false {
                    messageController?.sendMessages = true
                    messageController?.beginSending()
                }
            }
        }
        else if message.contains("stop") {
            Log.debug("Pausing message consumption")
            messageController?.sendMessages = false
        } else {
            Log.warning("Received message with unknown action, expected 'start' or 'stop': \(message)")
        }
    }
    
    private class MessageController {
        let consumer = Consumer()
        var exit: Bool = false
        var sendMessages: Bool = true
        weak var demoConsumeSocket: DemoConsumeSocket?
        private var queue = [KafkaConsumerRecord]()
        private let queueSemaphore = DispatchSemaphore(value: 1)
        
        init(demoConsumeSocket: DemoConsumeSocket) {
            self.demoConsumeSocket = demoConsumeSocket
        }
        
        func start() {
            beginConsuming()
            beginSending()
        }
        
        func beginConsuming() {
            // KafkaConsumer
            DispatchQueue.global(qos: .utility).async { [weak self] in
                
                while(!(self?.exit ?? true)) {
                    //Log.debug("Consuming messages from Kafka")
                    let records = self?.consumer.consume() ?? []
                    if !records.isEmpty {
                        Log.debug(records.description)
                    }
                    for record in records {
                        do {
                            var stockPurchase = try JSONDecoder().decode(StockPurchase.self, from: record.valueData)
                            if stockPurchase.price > 0 {
                                stockPurchase.topic = record.topic
                                let spDocument = try BSONEncoder().encode(stockPurchase)
								MONGO_CONNECTOR?.tradesCollection.insert(spDocument)
                                Log.debug("Consumed message: \(record)")
                                self?.enqueue(record: record)
                            }
                        } catch {
                            Log.error("Failed to decode StockPurchase: \(error)")
                            break
                        }
                    }
                }
                Log.debug("Closing consumer")
                self?.consumer.shutdown()
                Log.debug("Consumer closed")
            } 
        }
        
        func beginSending() {
            // Message sender
            DispatchQueue.global(qos: .utility).async { [weak self] in
                while(!(self?.exit ?? true) && self?.sendMessages ?? false) {
                    if let message = self?.dequeue() {
                        Log.debug("Updating session with new message \(message)")
                        do {
                            try self?.demoConsumeSocket?.currentConnection?.send(message: JSONEncoder().encode(message))
                        } catch {
                            Log.error("Failed to encode message: \(message)")
                        }
                    }
                }
            }
        }
        
        private func enqueue(record: KafkaConsumerRecord) {
            Log.debug("enqueue called")
            queueSemaphore.wait()
            queue.append(record)
            Log.debug("Added record to queue: \(record)")
            queueSemaphore.signal()
        }
        
        private func dequeue() -> KafkaConsumerRecord? {
            queueSemaphore.wait()
            guard let record = queue.first else {
                queueSemaphore.signal()
                return nil
            }
            queue.remove(at: 0)
            queueSemaphore.signal()
            return record
        }
    }
}
