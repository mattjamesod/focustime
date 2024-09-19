import SwiftUI
import Combine

@MainActor @Observable
class CountdownViewModel {
    private let timerLength: Duration
    private var runningTimer: AnyCancellable?
    
    private var secondsElapsed: Int = 0

    init(_ timerLength: Duration) {
        self.timerLength = timerLength
    }
    
    func start() {
        runningTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.secondsElapsed += 1
            }
    }
    
    func pause() {
        runningTimer?.cancel()
        runningTimer = nil
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
}

struct CountdownView: View {
    @State var countdown: CountdownViewModel = .init(.seconds(60))
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
                        .environment(countdown)
                }
            
            HStack {
                Button {
                    if countdown.isRunning {
                        countdown.pause()
                    }
                    else {
                        countdown.start()
                    }
                } label: {
                    Label(
                        countdown.isRunning ? "Pause" : "Play",
                        systemImage: countdown.isRunning ? "pause" : "play"
                    )
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .fontWeight(.bold)
                }
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
        }
        .onAppear {
            countdown.start()
        }
        .animation(.easeInOut, value: countdown.timeRemaining)
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
