import Foundation

/// A single Americano match between two pairs of players.
public struct Match: Identifiable, Codable {
    public let id: UUID
    /// Players on team A (indices into the Tournament's player list).
    public var teamA: [UUID]
    /// Players on team B (indices into the Tournament's player list).
    public var teamB: [UUID]
    /// Points scored by team A (0–16 by convention for Americano).
    public var scoreA: Int
    /// Points scored by team B (0–16 by convention for Americano).
    public var scoreB: Int
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        teamA: [UUID],
        teamB: [UUID],
        scoreA: Int = 0,
        scoreB: Int = 0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.teamA = teamA
        self.teamB = teamB
        self.scoreA = scoreA
        self.scoreB = scoreB
        self.isCompleted = isCompleted
    }
}
