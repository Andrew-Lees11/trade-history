// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "trade-history",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.6.0")),
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
      .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "9.0.0"),
      .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.0.0"),
      .package(url: "https://github.com/IBM-Swift/Health.git", from: "1.0.0"),
      .package(url: "git@github.ibm.com:IBM-Swift/Kitura-Kafka", .branch("master")),
      .package(url: "https://github.com/OpenKitten/MongoKitten", from: "5.0.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.1.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.0.0"),
    ],
    targets: [
      .target(name: "trade-history", dependencies: [ .target(name: "Application"), "Kitura" , "HeliumLogger"]),
      .target(name: "Application", dependencies: [ "Kitura", "CloudEnvironment", "SwiftMetrics", "Health", "KituraKafka", "MongoKitten", "Kitura-WebSocket", "KituraOpenAPI"

      ]),

      .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
    ]
)
