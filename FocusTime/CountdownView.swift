import SwiftUI
import Combine
import UserNotifications

// TODO: store the starting Date of the timer, and update it when app is opened

@MainActor @Observable
class CountdownViewModel {
    private let timerLength: Duration
    private let notifications: Notifications = .init()
    private var notificationID: String? = nil
    
    private var runningTimer: AnyCancellable?
    private var secondsElapsed: Int = 0

    init(_ timerLength: Duration) {
        self.timerLength = timerLength
    }
    
    func start() {
        notifications.requestAuthorization()
        self.notificationID = notifications.schedule(in: self.timeRemaining)
        
        runningTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.secondsElapsed += 1
            }
    }
    
    func playPause() {
        self.isRunning ? self.pause() : self.start()
    }
    
    func reset() {
        self.pause()
        self.secondsElapsed = 0
        
        if let id = self.notificationID {
            notifications.cancel(with: id)
            self.notificationID = nil
        }
    }
    
    var isRunning: Bool {
        runningTimer != nil
    }
    
    var timeRemaining: Duration {
        max(self.timerLength - .seconds(self.secondsElapsed), .zero)
    }
    
    var fractionRemaining: Double {
        Double(self.timeRemaining.components.seconds) / Double(self.timerLength.components.seconds)
    }
    
    private func pause() {
        runningTimer?.cancel()
        runningTimer = nil
        
        if let id = self.notificationID {
            notifications.cancel(with: id)
            self.notificationID = nil
        }
    }
}

struct CountdownView: View {
    @State var countdown: CountdownViewModel = .init(.seconds(10))
    @Namespace var namespace
    
    var body: some View {
        VStack(spacing: 36) {
            Text(countdown.timeRemaining.formatted(.time(pattern: .minuteSecond)))
                .contentTransition(.numericText(countsDown: true))
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .padding(72)
                .background {
                    CountdownCircle()
                }
            
            HStack {
                PauseButton()
                ResetButton()
            }
//            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
        }
        .onAppear {
            countdown.start()
        }
        .environment(countdown)
        .animation(.easeInOut, value: countdown.timeRemaining)
    }
}

struct PauseButton: View {
    @Environment(CountdownViewModel.self) var countdown
    
    var body: some View {
        Button {
            countdown.playPause()
        } label: {
            Label(
                countdown.isRunning ? "Pause" : "Play",
                systemImage: countdown.isRunning ? "pause" : "play"
            )
        }
        .contentTransition(.symbolEffect(.replace))
    }
}

struct ResetButton: View {
    @Environment(CountdownViewModel.self) var countdown
    
    var body: some View {
        Button {
            countdown.reset()
        } label: {
            Label("Reset", systemImage: "chevron.left.2")
        }
    }
}

struct CountdownCircle: View {
    @Environment(CountdownViewModel.self) var countdown
    
    let lineWidth: Double = 12
    
    var body: some View {
        Circle()
            .stroke(.ultraThinMaterial, lineWidth: self.lineWidth)
        
        Circle()
            .trim(from: 0, to: countdown.fractionRemaining)
            .stroke(.blue,
                style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.radians(1 * -0.5 * .pi))
            .rotationEffect(.radians((1 - countdown.fractionRemaining) * 2 * .pi))
            .foregroundStyle(.blue)
    }
}

#Preview {
    CountdownView()
}
