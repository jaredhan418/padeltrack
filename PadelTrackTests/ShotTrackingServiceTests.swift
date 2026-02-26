import XCTest
@testable import PadelTrackCore

final class ShotTrackingServiceTests: XCTestCase {

    var service: ShotTrackingService!
    let playerID = UUID()

    override func setUp() {
        super.setUp()
        service = ShotTrackingService()
    }

    func testRecordShot_appendsToShots() {
        service.recordShot(
            playerID: playerID,
            courtPosition: .init(x: 0.5, y: 0.5),
            type: .drive,
            outcome: .inPlay,
            isIn: true
        )
        XCTAssertEqual(service.shots.count, 1)
    }

    func testClearShots_removesAll() {
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .lob, outcome: .winner, isIn: true)
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .smash, outcome: .unforced, isIn: false)
        service.clearShots()
        XCTAssertTrue(service.shots.isEmpty)
    }

    func testShotsForPlayer_filtersCorrectly() {
        let otherID = UUID()
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .drive, outcome: .inPlay, isIn: true)
        service.recordShot(playerID: otherID, courtPosition: .zero, type: .volley, outcome: .winner, isIn: true)
        XCTAssertEqual(service.shots(for: playerID).count, 1)
        XCTAssertEqual(service.shots(for: otherID).count, 1)
    }

    func testStats_winners() {
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .smash, outcome: .winner, isIn: true)
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .drive, outcome: .inPlay, isIn: true)
        let stats = service.stats(for: playerID)
        XCTAssertEqual(stats.winners, 1)
        XCTAssertEqual(stats.totalShots, 2)
    }

    func testStats_inPercentage() {
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .drive, outcome: .inPlay, isIn: true)
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .drive, outcome: .unforced, isIn: false)
        let stats = service.stats(for: playerID)
        XCTAssertEqual(stats.inPercentage, 50.0, accuracy: 0.1)
    }

    func testStats_averageSpeed() throws {
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .serve, outcome: .inPlay, isIn: true, speedKmH: 120)
        service.recordShot(playerID: playerID, courtPosition: .zero, type: .serve, outcome: .inPlay, isIn: true, speedKmH: 80)
        let stats = service.stats(for: playerID)
        let avgSpeed = try XCTUnwrap(stats.averageSpeedKmH)
        XCTAssertEqual(avgSpeed, 100.0, accuracy: 0.1)
    }

    func testStats_noShots_inPercentageIsZero() {
        let stats = service.stats(for: playerID)
        XCTAssertEqual(stats.inPercentage, 0.0)
        XCTAssertNil(stats.averageSpeedKmH)
    }
}
