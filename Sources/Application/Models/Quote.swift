import Foundation

public struct Quote: Codable, Equatable {
    public var symbol: String?
    public var price: Double?
    public var date: String?
    public var time: Int?
    
    public init(symbol: String? = nil, price: Double? = nil, date: String? = nil, time: Int? = nil) {
        self.symbol = symbol
        self.price = price
        self.date = date
        self.time = time
    }
}
