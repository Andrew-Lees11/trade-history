import Foundation
import KituraKafka
import LoggerAPI

// Start Kafka instructions:
// brew cask install java
// brew install kafka
// brew services start zookeeper
// brew services start kafka

public class Consumer {
    let BOOTSTRAP_SERVER_ENV_KEY = "localhost:9092"
    let TOPIC_ENV_KEY = "stocktrader"
    let API_KEY = ""
    let KEYSTORE = "resources/security/certs.jks"
    let USERNAME = "token"
    let CONSUMER_GROUP_ID = "trade-history"
    var kafkaConsumer: KafkaConsumer?
    
    public init() {
        do {
            let config = KafkaConfig()
//            config.securityProtocol = .sasl_ssl
            config.groupId = CONSUMER_GROUP_ID
//            config.autoOffsetReset = .earliest
//            config.sslKeystoreLocation = KEYSTORE
//            config.sslKeystorePassword = "password"
//            config.saslMechanism = .plain
            kafkaConsumer = try KafkaConsumer(config: config)
            kafkaConsumer?.connect(brokers: BOOTSTRAP_SERVER_ENV_KEY)
            try kafkaConsumer?.subscribe(topics: [TOPIC_ENV_KEY])
        } catch {
            Log.error("Failed to create Kafka Consumer: \(error)")
            kafkaConsumer = nil
        }
    }
    
    public func consume() -> [KafkaConsumerRecord] {
        do {
            let records =  try kafkaConsumer?.poll()
            return records ?? []
        }
        catch {
            Log.error("Failed to poll Kafka Consumer: \(error)")
            return []
        }
    }
    
    public func isHealthy() -> Bool {
        return kafkaConsumer != nil
    }
    
    public func shutdown() {
        try? kafkaConsumer?.close()
    }
}
