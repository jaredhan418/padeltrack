import Foundation

/// Generates match schedules for Padel Americano tournaments.
///
/// Americano rules:
/// - Players rotate partners each round so everyone plays with/against everyone.
/// - Points are scored individually rather than by team.
/// - Requires an even number of players (minimum 4).
public struct AmericanoScheduler {

    // MARK: - Public API

    /// Generates all rounds for an Americano tournament.
    ///
    /// The algorithm uses a round-robin pair rotation:
    /// - For `n` players, there are `n - 1` rounds.
    /// - Each round produces `n / 2` courts (matches).
    /// - No player appears twice in the same round.
    ///
    /// - Parameters:
    ///   - players: List of participants. Must contain an even number of players ≥ 4.
    /// - Returns: Array of `Round` values; empty if player count is invalid.
    public static func generateRounds(for players: [Player]) -> [Round] {
        let n = players.count
        guard n >= 4, n % 2 == 0 else { return [] }

        var rounds: [Round] = []
        // Build rotation array (indices 0 ..< n).
        var rotation = Array(0 ..< n)

        for roundIndex in 0 ..< (n - 1) {
            var matches: [Match] = []
            // Pair players: (0,1), (2,3), (4,5) … form team A vs team B per court.
            // For each court we pick consecutive pairs from the rotation.
            let halfN = n / 2
            for courtIndex in stride(from: 0, to: halfN, by: 2) {
                let pA1 = players[rotation[courtIndex]].id
                let pA2 = players[rotation[courtIndex + 1]].id
                let pB1Index = halfN + courtIndex
                let pB2Index = halfN + courtIndex + 1
                // Guard against out-of-bounds when halfN is odd (shouldn't happen with even n).
                guard pB2Index < n else { continue }
                let pB1 = players[rotation[pB1Index]].id
                let pB2 = players[rotation[pB2Index]].id
                matches.append(Match(
                    teamA: [pA1, pA2],
                    teamB: [pB1, pB2]
                ))
            }
            rounds.append(Round(roundNumber: roundIndex + 1, matches: matches))
            // Rotate: fix position 0, rotate positions 1 ..< n.
            rotation = rotated(rotation)
        }
        return rounds
    }

    // MARK: - Private helpers

    /// Performs a single round-robin rotation keeping index 0 fixed.
    static func rotated(_ arr: [Int]) -> [Int] {
        guard arr.count > 1 else { return arr }
        var result = arr
        // Move last element to position 1; shift others right.
        let last = result.removeLast()
        result.insert(last, at: 1)
        return result
    }
}
