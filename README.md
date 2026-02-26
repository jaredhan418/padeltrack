# PadelTrack

**PadelTrack** is an iOS app (iOS 16+) that brings together three core padel features in one place:

| Feature | Description |
|---|---|
| 🏆 Americano Tournament | Organise Padel Americano events – auto-generates round schedules, tracks live scores and shows a running leaderboard |
| 📷 Electronic Line Judge | Uses the device camera + Apple's **Vision** framework to detect ball landings in real time (IN / OUT), similar to Swing Vision |
| 🎾 Shot Tracker | Tap the on-screen court diagram to record shots by type, outcome and landing position, with per-player statistics |

---

## Project Structure

```
PadelTrack/Sources/PadelTrack/
├── App/
│   ├── PadelTrackApp.swift          – App entry point (@main)
│   └── ContentView.swift            – Tab-bar root navigation
├── Models/
│   ├── Player.swift                 – Player data model
│   ├── Match.swift                  – Single match (team A vs team B, scores)
│   ├── Tournament.swift             – Americano tournament + leaderboard
│   └── Shot.swift                   – Shot record (type, outcome, position, speed)
├── Services/
│   ├── AmericanoScheduler.swift     – Round-robin pair scheduler
│   ├── BallDetectionService.swift   – AVFoundation + Vision ball detection
│   └── ShotTrackingService.swift    – Shot recording & statistics
└── Views/
    ├── Tournament/
    │   ├── TournamentSetupView.swift – Create tournament & add players
    │   ├── TournamentView.swift      – Rounds list + live leaderboard
    │   └── MatchScoreView.swift      – Enter match scores
    ├── LineJudge/
    │   ├── LineJudgeView.swift       – Camera-based IN/OUT detection UI
    │   └── CameraPreviewView.swift   – AVCaptureVideoPreviewLayer wrapper
    └── ShotTracker/
        └── ShotTrackerView.swift     – Interactive court diagram + stats

PadelTrackTests/
├── AmericanoSchedulerTests.swift    – Scheduler unit tests
├── TournamentLeaderboardTests.swift – Leaderboard accumulation tests
└── ShotTrackingServiceTests.swift   – Shot service unit tests
```

---

## Features

### 🏆 Americano Tournament Scheduler

- Supports 4–N players (even numbers only)
- Generates `n – 1` rounds using a round-robin rotation; each round assigns players to courts so nobody plays twice in the same round
- Points accumulate per player across all completed matches
- Live leaderboard ranks players by total points

### 📷 Electronic Line Judge

- **AVFoundation** streams live video from the rear camera at 720 p
- **Vision** (`VNDetectRectanglesRequest`) identifies the court boundary and tracks the ball position
- Each frame produces an **IN / OUT** verdict with a confidence percentage
- Ball speed is estimated from consecutive frame positions (km/h)
- Requires camera permission (`NSCameraUsageDescription` in `Info.plist`)

### 🎾 Shot Tracker

- Tap anywhere on the court diagram to pin a shot location
- Choose shot type (Drive, Bandeja, Víbora, Smash, Lob, Volley, Serve, Other) and outcome (Winner, Forced Error, Unforced Error, In Play)
- Per-player stats: total shots, winners, unforced errors, in-percentage, average speed

---

## Building

Open `Package.swift` in Xcode 15+ or add the sources to an existing Xcode project targeting **iOS 16+**.

Required `Info.plist` entries for the Line Judge feature:

```xml
<key>NSCameraUsageDescription</key>
<string>PadelTrack uses the camera to detect ball landings in real time.</string>
```

---

## Running Tests

```bash
swift test
```

All logic tests (scheduler, leaderboard, shot tracking) can run on macOS without a device.  
Camera/AVFoundation tests require a physical iOS device.
