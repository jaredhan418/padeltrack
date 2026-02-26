import Foundation

/// A padel player participating in an Americano tournament.
public struct Player: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    /// Cumulative points scored across all matches in the tournament.
    public var points: Int

    public init(id: UUID = UUID(), name: String, points: Int = 0) {
        self.id = id
        self.name = name
        self.points = points
    }
}
