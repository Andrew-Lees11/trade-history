import Foundation
import MongoKitten

// Mongo start instructions:
// brew install mongodb
// brew services start mongodb

// View database collections:
// mongo
// show dbs
// use TEST_MONGO_DATABASE
// show collections
// db.test_collection.find()

public class MongoConnector {
    static let MONGO_USER = ""
    //let MONGO_AUTH_DB = ""
    static let MONGO_PASSWORD = ""
    static let MONGO_IP = "localhost:"
    static let MONGO_PORT = 27017
    static let MONGO_DATABASE = "/TEST_MONGO_DATABASE"
    
    let mongoURI = "mongodb://\(MONGO_USER)\(MONGO_PASSWORD)\(MONGO_IP)\(MONGO_PORT)\(MONGO_DATABASE)"
    public let database: Database
    public let tradesCollection: MongoKitten.Collection
    
    public init() throws {
        print(mongoURI)
        self.database = try Database.synchronousConnect(mongoURI)
        self.tradesCollection = database["test_collection"]
    }
}
