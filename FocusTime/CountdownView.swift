import SwiftUI
import Combine

@MainActor @Observable
class CountdownViewModel {
    let timerLength: Duration

    init(timerLength: Duration = .seconds(4)) {
        self.timerLength = timerLength
    }
    
    var secondsElapsed: Int = 0
    
    private var cancellable: AnyCancellable?
    
    func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.secondsElapsed += 1
            }
    }
    
    var timeRemaining: Duration {
        max(self.timerLength - .seconds(self.secondsElapsed), .zero)
    }
    
    var timeRemainingStr: String {
        timeRemaining.formatted(.time(pattern: .minuteSecond))
    }
}

struct CountdownView: View {
    @State var viewModel: CountdownViewModel = .init()
    
    var body: some View {
        Text(viewModel.timeRemainingStr)
            .onAppear {
                viewModel.startTimer()
            }
    }
}

#Preview {
    CountdownView()
}
