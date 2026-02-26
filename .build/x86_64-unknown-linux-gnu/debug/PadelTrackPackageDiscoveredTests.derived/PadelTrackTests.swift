import XCTest
@testable import PadelTrackTests

fileprivate extension AmericanoSchedulerTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__AmericanoSchedulerTests = [
        ("testEmptyPlayers_returnsEmpty", testEmptyPlayers_returnsEmpty),
        ("testMatchesPerRound_4Players", testMatchesPerRound_4Players),
        ("testMatchesPerRound_8Players", testMatchesPerRound_8Players),
        ("testNoPlayerDuplicatePerRound", testNoPlayerDuplicatePerRound),
        ("testOddPlayerCount_returnsEmpty", testOddPlayerCount_returnsEmpty),
        ("testRotatedArray", testRotatedArray),
        ("testRoundCount_4Players", testRoundCount_4Players),
        ("testRoundCount_6Players", testRoundCount_6Players),
        ("testRoundCount_8Players", testRoundCount_8Players),
        ("testRoundNumbersAreSequential", testRoundNumbersAreSequential),
        ("testTooFewPlayers_returnsEmpty", testTooFewPlayers_returnsEmpty)
    ]
}

fileprivate extension ShotTrackingServiceTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ShotTrackingServiceTests = [
        ("testClearShots_removesAll", testClearShots_removesAll),
        ("testRecordShot_appendsToShots", testRecordShot_appendsToShots),
        ("testShotsForPlayer_filtersCorrectly", testShotsForPlayer_filtersCorrectly),
        ("testStats_averageSpeed", testStats_averageSpeed),
        ("testStats_inPercentage", testStats_inPercentage),
        ("testStats_noShots_inPercentageIsZero", testStats_noShots_inPercentageIsZero),
        ("testStats_winners", testStats_winners)
    ]
}

fileprivate extension TournamentLeaderboardTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__TournamentLeaderboardTests = [
        ("testLeaderboard_accumulatesPointsCorrectly", testLeaderboard_accumulatesPointsCorrectly),
        ("testLeaderboard_ignoresIncompleteMatches", testLeaderboard_ignoresIncompleteMatches),
        ("testLeaderboard_withNoCompletedMatches_allZero", testLeaderboard_withNoCompletedMatches_allZero)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __PadelTrackTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AmericanoSchedulerTests.__allTests__AmericanoSchedulerTests),
        testCase(ShotTrackingServiceTests.__allTests__ShotTrackingServiceTests),
        testCase(TournamentLeaderboardTests.__allTests__TournamentLeaderboardTests)
    ]
}