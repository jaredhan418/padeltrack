#if canImport(SwiftUI)
import SwiftUI
import PadelTrackCore

/// Root navigation view for PadelTrack.
struct ContentView: View {
    var body: some View {
        TabView {
            TournamentSetupView()
                .tabItem {
                    Label("Tournament", systemImage: "trophy.fill")
                }

            LineJudgeView()
                .tabItem {
                    Label("Line Judge", systemImage: "camera.fill")
                }

            ShotTrackerView()
                .tabItem {
                    Label("Shot Tracker", systemImage: "sportscourt.fill")
                }
        }
    }
}
#endif
