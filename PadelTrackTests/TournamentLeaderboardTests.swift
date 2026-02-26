import XCTest
@testable import PadelTrackCore

final class TournamentLeaderboardTests: XCTestCase {

    func testLeaderboard_withNoCompletedMatches_allZero() {
        let players = [Player(name: "Alice"), Player(name: "Bob"),
                       Player(name: "Carol"), Player(name: "Dave")]
        let rounds = AmericanoScheduler.generateRounds(for: players)
        let tournament = Tournament(name: "Test", players: players, rounds: rounds)
        let board = tournament.leaderboard()
        XCTAssertEqual(board.count, 4)
        XCTAssertTrue(board.allSatisfy { $0.points == 0 })
    }

    func testLeaderboard_accumulatesPointsCorrectly() {
        var players = [Player(name: "Alice"), Player(name: "Bob"),
                       Player(name: "Carol"), Player(name: "Dave")]
        var rounds = AmericanoScheduler.generateRounds(for: players)
        // Mark first match of round 1 as completed: teamA scores 10, teamB scores 6
        rounds[0].matches[0].scoreA = 10
        rounds[0].matches[0].scoreB = 6
        rounds[0].matches[0].isCompleted = true
        let tournament = Tournament(name: "Test", players: players, rounds: rounds)
        let board = tournament.leaderboard()
        // Top two players should have 10 pts each; bottom two should have 6 pts each
        XCTAssertEqual(board[0].points, 10)
        XCTAssertEqual(board[1].points, 10)
        XCTAssertEqual(board[2].points, 6)
        XCTAssertEqual(board[3].points, 6)
    }

    func testLeaderboard_ignoresIncompleteMatches() {
        let players = [Player(name: "Alice"), Player(name: "Bob"),
                       Player(name: "Carol"), Player(name: "Dave")]
        var rounds = AmericanoScheduler.generateRounds(for: players)
        // Set score but do NOT mark as completed
        rounds[0].matches[0].scoreA = 16
        rounds[0].matches[0].scoreB = 0
        rounds[0].matches[0].isCompleted = false
        let tournament = Tournament(name: "Test", players: players, rounds: rounds)
        let board = tournament.leaderboard()
        XCTAssertTrue(board.allSatisfy { $0.points == 0 })
    }
}
