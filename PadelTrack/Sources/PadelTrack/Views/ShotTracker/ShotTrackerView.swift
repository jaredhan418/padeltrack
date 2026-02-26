#if canImport(SwiftUI)
import SwiftUI
import PadelTrackCore

/// Interactive shot tracker – tap the court diagram to record a shot location,
/// then fill in the shot type and outcome.
public struct ShotTrackerView: View {

    @StateObject private var service = ObservableShotTrackingService()
    @State private var players: [Player] = [
        Player(name: "Player 1"),
        Player(name: "Player 2"),
        Player(name: "Player 3"),
        Player(name: "Player 4")
    ]
    @State private var selectedPlayerIndex = 0
    @State private var pendingPosition: CourtPoint?
    @State private var selectedType: ShotType = .drive
    @State private var selectedOutcome: ShotOutcome = .inPlay
    @State private var showShotEntry = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                playerPicker
                courtDiagram
                statsBar
            }
            .navigationTitle("Shot Tracker")
            .sheet(isPresented: $showShotEntry) {
                shotEntrySheet
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { service.clearShots() }
                        .foregroundStyle(.red)
                }
            }
        }
    }

    // MARK: - Player picker

    private var playerPicker: some View {
        Picker("Player", selection: $selectedPlayerIndex) {
            ForEach(players.indices, id: \.self) { idx in
                Text(players[idx].name).tag(idx)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    // MARK: - Court diagram

    private var courtDiagram: some View {
        GeometryReader { geo in
            ZStack {
                // Court background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(.white, lineWidth: 2)
                    )

                // Center line
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 2, height: geo.size.height)
                    .frame(maxWidth: .infinity)

                // Service boxes
                let thirds = geo.size.width / 3
                ForEach([thirds, thirds * 2], id: \.self) { x in
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 1, height: geo.size.height * 0.4)
                        .position(x: x, y: geo.size.height * 0.2)
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 1, height: geo.size.height * 0.4)
                        .position(x: x, y: geo.size.height * 0.8)
                }

                // Recorded shots
                ForEach(service.shots) { shot in
                    Circle()
                        .fill(shot.isIn ? Color.blue.opacity(0.8) : Color.red.opacity(0.8))
                        .frame(width: 10, height: 10)
                        .position(
                            x: CGFloat(shot.courtPosition.x) * geo.size.width,
                            y: CGFloat(shot.courtPosition.y) * geo.size.height
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let normalized = CourtPoint(
                    x: Double(location.x / geo.size.width),
                    y: Double(location.y / geo.size.height)
                )
                pendingPosition = normalized
                showShotEntry = true
            }
        }
        .aspectRatio(0.5, contentMode: .fit)
        .padding()
    }

    // MARK: - Stats bar

    private var statsBar: some View {
        let player = players[selectedPlayerIndex]
        let stats = service.stats(for: player.id)
        return HStack(spacing: 20) {
            statItem(title: "Shots", value: "\(stats.totalShots)")
            statItem(title: "Winners", value: "\(stats.winners)")
            statItem(title: "Errors", value: "\(stats.unforcedErrors)")
            statItem(title: "In %", value: String(format: "%.0f%%", stats.inPercentage))
            if let speed = stats.averageSpeedKmH {
                statItem(title: "Avg km/h", value: String(format: "%.0f", speed))
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - Shot entry sheet

    private var shotEntrySheet: some View {
        NavigationStack {
            Form {
                Section("Shot Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(ShotType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Section("Outcome") {
                    Picker("Outcome", selection: $selectedOutcome) {
                        ForEach(ShotOutcome.allCases, id: \.self) { o in
                            Text(o.rawValue).tag(o)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Landing") {
                    Toggle("Ball In", isOn: Binding(
                        get: { selectedOutcome != .unforced && selectedOutcome != .forced },
                        set: { _ in }
                    ))
                    .disabled(true)
                }
            }
            .navigationTitle("Record Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showShotEntry = false
                        pendingPosition = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveShot()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Save shot

    private func saveShot() {
        guard let pos = pendingPosition else { return }
        let player = players[selectedPlayerIndex]
        let isIn = selectedOutcome == .inPlay || selectedOutcome == .winner
        service.recordShot(
            playerID: player.id,
            courtPosition: pos,
            type: selectedType,
            outcome: selectedOutcome,
            isIn: isIn
        )
        showShotEntry = false
        pendingPosition = nil
    }
}
#endif
