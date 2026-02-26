#if canImport(SwiftUI)
import SwiftUI
import PadelTrackCore

/// Displays all rounds of an Americano tournament and the live leaderboard.
public struct TournamentView: View {

    @State private var tournament: Tournament

    public init(tournament: Tournament) {
        _tournament = State(initialValue: tournament)
    }

    public var body: some View {
        List {
            leaderboardSection
            roundsSection
        }
        .navigationTitle(tournament.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var leaderboardSection: some View {
        Section("Leaderboard") {
            ForEach(Array(tournament.leaderboard().enumerated()), id: \.element.id) { index, player in
                HStack {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .leading)
                    Text(player.name)
                    Spacer()
                    Text("\(player.points) pts")
                        .bold()
                        .foregroundStyle(index == 0 ? .yellow : .primary)
                }
            }
        }
    }

    private var roundsSection: some View {
        ForEach($tournament.rounds) { $round in
            Section("Round \(round.roundNumber)") {
                ForEach($round.matches) { $match in
                    MatchRowView(match: $match, players: tournament.players)
                }
            }
        }
    }
}

// MARK: - Match row with inline score entry

private struct MatchRowView: View {
    @Binding var match: Match
    let players: [Player]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(teamLabel(match.teamA) + " vs " + teamLabel(match.teamB))
                .font(.subheadline)
                .bold()

            if match.isCompleted {
                HStack {
                    Text("\(match.scoreA) – \(match.scoreB)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } else {
                NavigationLink("Enter Score") {
                    MatchScoreView(match: $match, players: players)
                }
                .font(.footnote)
            }
        }
        .padding(.vertical, 2)
    }

    private func teamLabel(_ ids: [UUID]) -> String {
        ids.compactMap { id in players.first { $0.id == id }?.name }.joined(separator: " & ")
    }
}
#endif
