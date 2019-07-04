## Trade History

This project is a Kitura swift version of the [IBM trade-history](https://github.com/IBMStockTrader/trade-history) project.

It features websockets, routing, MongoDB and Kafka working together

To begin the proecesses to run this locally enter the following commands:

#### Kafka:
```
brew cask install java
brew install kafka
brew services start zookeeper
brew services start kafka
```

#### MongoDB

```
brew install mongodb
brew services start mongodb
```

View messages:

```
mongo
show dbs
use TEST_MONGO_DATABASE
show collections
db.test_collection.find()
```

#### Start demo

Start the server and go to [localhost:8080](http://localhost:8080/)

- Run websocket to begin consuming messages
- Stop websockets to stop consuming messages
- Produce a message to kafka using the form
- Read the latest message using the GET button
- Optionally us [OpenAPI](http://localhost:8080/openapi/ui/#/) to send and view REST routes.
