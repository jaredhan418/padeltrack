#if canImport(SwiftUI)
import SwiftUI
import PadelTrackCore

/// Allows entering the score for a single Americano match.
public struct MatchScoreView: View {

    @Binding var match: Match
    let players: [Player]

    @State private var scoreAText: String = ""
    @State private var scoreBText: String = ""
    @Environment(\.dismiss) private var dismiss

    public init(match: Binding<Match>, players: [Player]) {
        _match = match
        self.players = players
        _scoreAText = State(initialValue: "\(match.wrappedValue.scoreA)")
        _scoreBText = State(initialValue: "\(match.wrappedValue.scoreB)")
    }

    public var body: some View {
        Form {
            Section("Team A – \(teamLabel(match.teamA))") {
                HStack {
                    Text("Points")
                    Spacer()
                    TextField("0", text: $scoreAText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }

            Section("Team B – \(teamLabel(match.teamB))") {
                HStack {
                    Text("Points")
                    Spacer()
                    TextField("0", text: $scoreBText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }

            Section {
                Button("Save Score") {
                    saveScore()
                }
                .disabled(!isValid)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Enter Score")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private var isValid: Bool {
        Int(scoreAText) != nil && Int(scoreBText) != nil
    }

    private func saveScore() {
        guard let a = Int(scoreAText), let b = Int(scoreBText) else { return }
        match.scoreA = a
        match.scoreB = b
        match.isCompleted = true
        dismiss()
    }

    private func teamLabel(_ ids: [UUID]) -> String {
        ids.compactMap { id in players.first { $0.id == id }?.name }.joined(separator: " & ")
    }
}
#endif
