import Foundation
import KituraContracts
import LoggerAPI
import Kitura
import MongoKitten

extension App {
    
    func initializeTradeRoutes() {
        
        router.get("/latestBuy", handler: latestBuyHandler)
        router.get("/trades", handler: tradesHandler)
        router.get("/trades/:owner/:symbol", handler: tradesSymbolHandler)
        router.get("/shares/:owner/:symbol", handler: sharesSymbolHandler)
        router.get("/shares", handler: sharesHandler)
        router.get("/notional/:owner", handler: notionalHandler)
        router.get("/returns/:owner", handler: returnsHandler)
    }    

    func latestBuyHandler(completion: @escaping (StockPurchase?, RequestError?) -> Void) {
        let stockPurchase = mongoConnector.tradesCollection.find().decode(StockPurchase.self).getAllResults()
        stockPurchase.whenSuccess { (stockPurchase) in
            completion(stockPurchase.last, nil)
        }
    }
    
    func tradesHandler(owner: String, completion: @escaping (Transactions?, RequestError?) -> Void) {
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner).decode(StockPurchase.self).getAllResults()
        stockPurchases.whenSuccess { purchases in
            completion(Transactions(transactions: purchases), nil)
        }
    }
    
    func tradesSymbolHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let owner = request.parameters["owner"], let symbol = request.parameters["symbol"] else {
            try response.send(status: .badRequest).end()
            return 
        }
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner && "symbol" == symbol).decode(StockPurchase.self).getAllResults()
        stockPurchases.whenSuccess { purchases in
            response.send(Transactions(transactions: purchases))
            next()
        }
    }
    
    func sharesSymbolHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let owner = request.parameters["owner"], let symbol = request.parameters["symbol"] else {
            try response.send(status: .badRequest).end()
            return 
        }
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner && "symbol" == symbol)
            .decode(StockPurchase.self)
            .getAllResults()
        stockPurchases.whenSuccess { purchases in
            let sumOfShares = purchases.reduce(0) { $0 + $1.shares }
            response.send(Shares(shares: [[symbol: sumOfShares]]))
            next()
        }
    }
    
    func sharesHandler(owner: String, completion: @escaping (Shares?, RequestError?) -> Void) {
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner)
            .decode(StockPurchase.self)
            .getAllResults()
        stockPurchases.whenSuccess { purchases in
            let shares = purchases.reduce(into: [String: Int]()) {
                $0[$1.symbol] = $0[$1.symbol] ?? 0 + $1.shares
            }
            completion(Shares(shares: [shares]), nil)
        }
    }
    
    func notionalHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let owner = request.parameters["owner"] else {
            try response.send(status: .badRequest).end()
            return 
        }
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner)
            .decode(StockPurchase.self)
            .getAllResults()
        stockPurchases.whenSuccess { purchases in
            let notional = purchases.reduce(0) { $0 + $1.notional }
            response.send(notional)
            next()
        }
    }
    
    struct currentValueQuery: QueryParams {
        let currentValue: Double
    }
    
    func returnsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let owner = request.parameters["owner"],
            let portfolioValue = request.getQueryParameters(as: currentValueQuery.self)
            else {
                try response.send(status: .badRequest).end()
                return 
        }
        let stockPurchases = mongoConnector.tradesCollection.find("owner" == owner)
            .decode(StockPurchase.self)
            .getAllResults()
        stockPurchases.whenSuccess { purchases in
            let notional = purchases.reduce(0) { $0 + $1.notional }
            let commissions = purchases.reduce(0) { $0 + $1.commission }
            let profits = portfolioValue.currentValue - notional - commissions
            let roi = profits/notional * 100
            response.send(roi)
            next()
        }        
    }
}
