import Foundation
import KituraKafka
import KituraContracts
import LoggerAPI

extension App {
    static var kafkaProducer: KafkaProducer?
    
    func initializeProducerRoutes() {
        do {
            App.kafkaProducer = try KafkaProducer()
            App.kafkaProducer?.connect(brokers: "localhost:9092") 
        } catch {
            Log.error("Failed to create Kafka producer: \(error)")
        }
        router.post("/produce", handler: produceHandler)
    }
    
    func produceHandler(purchase: StockPurchase, completion: @escaping (StockPurchase?, RequestError?) -> Void) {
        do {
			var updatablePurchase = purchase
			updatablePurchase.topic = updatablePurchase.topic ?? "stocktrader"
            let purchaseData = try JSONEncoder().encode(updatablePurchase)
			App.kafkaProducer?.send(producerRecord: KafkaProducerRecord(topic: updatablePurchase.topic ?? "stocktrader", value: purchaseData))
            completion(purchase, nil)
        } catch {
            Log.error("Failed to encoded purchase: \(purchase)")
            completion(nil, .internalServerError)
        }
    }
}
