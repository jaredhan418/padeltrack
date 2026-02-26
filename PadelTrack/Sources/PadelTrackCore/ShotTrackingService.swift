import Foundation

/// Records and manages shot events during a padel match.
public final class ShotTrackingService {

    // MARK: - State

    public private(set) var shots: [Shot] = []

    // MARK: - Public API

    public init() {}

    /// Records a new shot for the given player.
    @discardableResult
    public func recordShot(
        playerID: UUID,
        courtPosition: CourtPoint,
        type: ShotType,
        outcome: ShotOutcome,
        isIn: Bool,
        speedKmH: Double? = nil
    ) -> Shot {
        let shot = Shot(
            playerID: playerID,
            courtPosition: courtPosition,
            type: type,
            outcome: outcome,
            isIn: isIn,
            speedKmH: speedKmH
        )
        shots.append(shot)
        return shot
    }

    /// Removes all recorded shots for the current session.
    public func clearShots() {
        shots.removeAll()
    }

    /// Returns all shots for a specific player.
    public func shots(for playerID: UUID) -> [Shot] {
        shots.filter { $0.playerID == playerID }
    }

    // MARK: - Statistics

    public struct PlayerStats {
        public let playerID: UUID
        public let totalShots: Int
        public let winners: Int
        public let unforcedErrors: Int
        public let forcedErrors: Int
        public let inPercentage: Double
        public let averageSpeedKmH: Double?
    }

    /// Computes shot statistics for a player.
    public func stats(for playerID: UUID) -> PlayerStats {
        let playerShots = shots(for: playerID)
        let total = playerShots.count
        let winners = playerShots.filter { $0.outcome == .winner }.count
        let unforced = playerShots.filter { $0.outcome == .unforced }.count
        let forced = playerShots.filter { $0.outcome == .forced }.count
        let inCount = playerShots.filter { $0.isIn }.count
        let inPct = total > 0 ? Double(inCount) / Double(total) * 100.0 : 0.0
        let speeds = playerShots.compactMap { $0.speedKmH }
        let avgSpeed: Double? = speeds.isEmpty ? nil : speeds.reduce(0, +) / Double(speeds.count)
        return PlayerStats(
            playerID: playerID,
            totalShots: total,
            winners: winners,
            unforcedErrors: unforced,
            forcedErrors: forced,
            inPercentage: inPct,
            averageSpeedKmH: avgSpeed
        )
    }
}
