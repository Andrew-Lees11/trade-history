import Foundation

struct StockPurchase: Codable {
    var topic: String?
    let id: String
    let owner: String
    let symbol: String
    let shares: Int
    let price: Double
    let notional: Double
    let when: String
    let commission: Double
    
    init(id: String, owner: String, symbol: String, shares: Int, price: Double, when: String, commission: Double) {
        self.id = id
        self.owner = owner
        self.symbol = symbol
        self.shares = shares
        self.price = price
        self.notional = Double(shares) * price
        self.when = when
        self.commission = commission
    }
}
