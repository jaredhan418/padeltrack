import Foundation

/// A round in an Americano tournament (all courts play simultaneously).
public struct Round: Identifiable, Codable {
    public let id: UUID
    public var roundNumber: Int
    public var matches: [Match]

    public init(id: UUID = UUID(), roundNumber: Int, matches: [Match]) {
        self.id = id
        self.roundNumber = roundNumber
        self.matches = matches
    }
}

/// An Americano-format padel tournament.
///
/// Each player partners with every other player across rounds.
/// Points are accumulated individually – the player with the most points wins.
public struct Tournament: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var players: [Player]
    public var rounds: [Round]
    /// Maximum number of rallying points per match (commonly 16 or 24).
    public var pointsPerMatch: Int
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        players: [Player],
        rounds: [Round] = [],
        pointsPerMatch: Int = 16,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.rounds = rounds
        self.pointsPerMatch = pointsPerMatch
        self.createdAt = createdAt
    }

    /// Returns the leaderboard sorted by accumulated points (descending).
    public func leaderboard() -> [Player] {
        var accumulated: [UUID: Int] = [:]
        for player in players {
            accumulated[player.id] = 0
        }
        for round in rounds {
            for match in round.matches where match.isCompleted {
                for pid in match.teamA { accumulated[pid, default: 0] += match.scoreA }
                for pid in match.teamB { accumulated[pid, default: 0] += match.scoreB }
            }
        }
        return players
            .map { p -> Player in
                var copy = p
                copy.points = accumulated[p.id] ?? 0
                return copy
            }
            .sorted { $0.points > $1.points }
    }
}
