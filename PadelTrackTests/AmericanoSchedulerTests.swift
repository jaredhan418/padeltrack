import XCTest
@testable import PadelTrackCore

final class AmericanoSchedulerTests: XCTestCase {

    // MARK: - Helper

    private func makePlayers(_ count: Int) -> [Player] {
        (0 ..< count).map { Player(name: "P\($0)") }
    }

    // MARK: - Round count

    func testRoundCount_4Players() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(4))
        XCTAssertEqual(rounds.count, 3, "4 players → 3 rounds")
    }

    func testRoundCount_6Players() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(6))
        XCTAssertEqual(rounds.count, 5, "6 players → 5 rounds")
    }

    func testRoundCount_8Players() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(8))
        XCTAssertEqual(rounds.count, 7, "8 players → 7 rounds")
    }

    // MARK: - Match count per round

    func testMatchesPerRound_4Players() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(4))
        for round in rounds {
            XCTAssertEqual(round.matches.count, 1, "4 players → 1 match per round")
        }
    }

    func testMatchesPerRound_8Players() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(8))
        for round in rounds {
            XCTAssertEqual(round.matches.count, 2, "8 players → 2 matches per round")
        }
    }

    // MARK: - Each player appears exactly once per round

    func testNoPlayerDuplicatePerRound() {
        let players = makePlayers(8)
        let rounds = AmericanoScheduler.generateRounds(for: players)
        for round in rounds {
            var seen = Set<UUID>()
            for match in round.matches {
                for pid in match.teamA + match.teamB {
                    XCTAssertFalse(seen.contains(pid), "Player \(pid) appears twice in round \(round.roundNumber)")
                    seen.insert(pid)
                }
            }
            XCTAssertEqual(seen.count, players.count)
        }
    }

    // MARK: - Invalid inputs

    func testOddPlayerCount_returnsEmpty() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(5))
        XCTAssertTrue(rounds.isEmpty)
    }

    func testTooFewPlayers_returnsEmpty() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(2))
        XCTAssertTrue(rounds.isEmpty)
    }

    func testEmptyPlayers_returnsEmpty() {
        let rounds = AmericanoScheduler.generateRounds(for: [])
        XCTAssertTrue(rounds.isEmpty)
    }

    // MARK: - Round numbers

    func testRoundNumbersAreSequential() {
        let rounds = AmericanoScheduler.generateRounds(for: makePlayers(4))
        for (index, round) in rounds.enumerated() {
            XCTAssertEqual(round.roundNumber, index + 1)
        }
    }

    // MARK: - Rotation helper

    func testRotatedArray() {
        let original = [0, 1, 2, 3]
        let rotated = AmericanoScheduler.rotated(original)
        // Last element moved to position 1, rest shifted
        XCTAssertEqual(rotated[0], 0)
        XCTAssertEqual(rotated[1], 3)
        XCTAssertEqual(rotated[2], 1)
        XCTAssertEqual(rotated[3], 2)
    }
}
