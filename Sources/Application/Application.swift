import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import MongoKitten
import KituraOpenAPI
import KituraWebSocket
import KituraKafka

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    let mongoConnector: MongoConnector
    
    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
        self.mongoConnector = try MongoConnector()
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        initializeTradeRoutes()
        initializeProducerRoutes()
        WebSocket.register(service: DemoConsumeSocket(), onPath: "/democonsume")
        router.all("/", middleware: StaticFileServer())
        KituraOpenAPI.addEndpoints(to: router)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
    

}
