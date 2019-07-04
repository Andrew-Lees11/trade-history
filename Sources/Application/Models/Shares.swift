struct Shares: Codable {
    let shares: [[String: Int]]
    init(shares: [[String: Int]]) {
        self.shares = shares
    }
}
