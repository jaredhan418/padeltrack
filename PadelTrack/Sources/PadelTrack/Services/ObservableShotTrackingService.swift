#if canImport(SwiftUI)
import Combine
import PadelTrackCore

/// An `ObservableObject` wrapper around `ShotTrackingService` for use in SwiftUI views.
public final class ObservableShotTrackingService: ObservableObject {

    @Published public private(set) var shots: [Shot] = []

    private let service = ShotTrackingService()

    public init() {}

    @discardableResult
    public func recordShot(
        playerID: UUID,
        courtPosition: CourtPoint,
        type: ShotType,
        outcome: ShotOutcome,
        isIn: Bool,
        speedKmH: Double? = nil
    ) -> Shot {
        let shot = service.recordShot(
            playerID: playerID,
            courtPosition: courtPosition,
            type: type,
            outcome: outcome,
            isIn: isIn,
            speedKmH: speedKmH
        )
        shots = service.shots
        return shot
    }

    public func clearShots() {
        service.clearShots()
        shots = service.shots
    }

    public func stats(for playerID: UUID) -> ShotTrackingService.PlayerStats {
        service.stats(for: playerID)
    }
}
#endif
