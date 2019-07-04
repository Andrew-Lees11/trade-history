struct Transactions: Codable {
    let transactions: [StockPurchase]
    init(transactions: [StockPurchase]) {
        self.transactions = transactions
    }
}
