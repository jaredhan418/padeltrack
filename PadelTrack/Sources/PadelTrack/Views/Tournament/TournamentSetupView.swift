#if canImport(SwiftUI)
import SwiftUI
import PadelTrackCore

/// View for creating a new Americano tournament and starting it.
public struct TournamentSetupView: View {

    @State private var tournamentName: String = ""
    @State private var playerName: String = ""
    @State private var players: [Player] = []
    @State private var pointsPerMatch: Int = 16
    @State private var createdTournament: Tournament?
    @State private var showingTournament = false

    private let pointOptions = [12, 16, 20, 24]

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Tournament") {
                    TextField("Tournament name", text: $tournamentName)
                }

                Section("Points per match") {
                    Picker("Points", selection: $pointsPerMatch) {
                        ForEach(pointOptions, id: \.self) { pts in
                            Text("\(pts)").tag(pts)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Add Players (minimum 4, even number)") {
                    HStack {
                        TextField("Player name", text: $playerName)
                        Button("Add") {
                            addPlayer()
                        }
                        .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    ForEach(players) { player in
                        Text(player.name)
                    }
                    .onDelete { indexSet in
                        players.remove(atOffsets: indexSet)
                    }
                }

                Section {
                    Button("Generate Tournament") {
                        generateTournament()
                    }
                    .disabled(!canGenerate)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("New Tournament")
            .navigationDestination(isPresented: $showingTournament) {
                if let tournament = createdTournament {
                    TournamentView(tournament: tournament)
                }
            }
        }
    }

    // MARK: - Helpers

    private var canGenerate: Bool {
        players.count >= 4 && players.count % 2 == 0 &&
        !tournamentName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addPlayer() {
        let name = playerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        players.append(Player(name: name))
        playerName = ""
    }

    private func generateTournament() {
        let rounds = AmericanoScheduler.generateRounds(for: players)
        createdTournament = Tournament(
            name: tournamentName,
            players: players,
            rounds: rounds,
            pointsPerMatch: pointsPerMatch
        )
        showingTournament = true
    }
}
#endif
