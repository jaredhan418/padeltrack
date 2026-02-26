import Foundation

/// A 2-D point on the court, with coordinates normalised to [0, 1].
/// Used in place of `CGPoint` so that `PadelTrackCore` remains cross-platform.
public struct CourtPoint: Codable, Hashable {
    public var x: Double
    public var y: Double

    public static let zero = CourtPoint(x: 0, y: 0)

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// Classification of a shot outcome.
public enum ShotOutcome: String, Codable, CaseIterable {
    case winner = "Winner"
    case forced  = "Forced Error"
    case unforced = "Unforced Error"
    case inPlay  = "In Play"
}

/// Type of shot hit.
public enum ShotType: String, Codable, CaseIterable {
    case drive    = "Drive"
    case bandeja  = "Bandeja"
    case vibora   = "Víbora"
    case smash    = "Smash"
    case lob      = "Lob"
    case volley   = "Volley"
    case serve    = "Serve"
    case other    = "Other"
}

/// A single recorded shot during a padel match.
public struct Shot: Identifiable, Codable {
    public let id: UUID
    public var playerID: UUID
    public var timestamp: Date
    /// Normalized court position (0–1 in both x and y).
    public var courtPosition: CourtPoint
    public var type: ShotType
    public var outcome: ShotOutcome
    /// Whether the ball landed in (true) or out (false).
    public var isIn: Bool
    /// Estimated ball speed in km/h (nil if unavailable).
    public var speedKmH: Double?

    public init(
        id: UUID = UUID(),
        playerID: UUID,
        timestamp: Date = Date(),
        courtPosition: CourtPoint = .zero,
        type: ShotType = .other,
        outcome: ShotOutcome = .inPlay,
        isIn: Bool = true,
        speedKmH: Double? = nil
    ) {
        self.id = id
        self.playerID = playerID
        self.timestamp = timestamp
        self.courtPosition = courtPosition
        self.type = type
        self.outcome = outcome
        self.isIn = isIn
        self.speedKmH = speedKmH
    }
}
