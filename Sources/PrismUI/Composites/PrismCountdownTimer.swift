import SwiftUI

/// Animated countdown timer with circular progress indicator.
public struct PrismCountdownTimer: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let totalSeconds: TimeInterval
    private let onComplete: (() -> Void)?
    private let showLabel: Bool

    @State private var remaining: TimeInterval
    @State private var timer: Timer?
    @State private var isRunning = false

    public init(
        seconds: TimeInterval,
        autoStart: Bool = true,
        showLabel: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        self.totalSeconds = seconds
        self.showLabel = showLabel
        self.onComplete = onComplete
        self._remaining = State(initialValue: seconds)
        self._isRunning = State(initialValue: autoStart)
    }

    public var body: some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            ZStack {
                Circle()
                    .stroke(theme.color(.surfaceSecondary), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        reduceMotion ? nil : .linear(duration: 1),
                        value: remaining
                    )

                Text(formattedTime)
                    .font(TypographyToken.title2.font(weight: .semibold).monospacedDigit())
                    .foregroundStyle(theme.color(.onBackground))
                    .contentTransition(.numericText())
            }
            .frame(width: 120, height: 120)

            if showLabel {
                Text(isRunning ? "Running" : (remaining <= 0 ? "Complete" : "Paused"))
                    .font(TypographyToken.caption.font(weight: .medium))
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
        .onAppear {
            if isRunning { startTimer() }
        }
        .onDisappear { stopTimer() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Countdown timer")
        .accessibilityValue("\(Int(remaining)) seconds remaining")
    }

    private var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return remaining / totalSeconds
    }

    private var progressColor: Color {
        if remaining <= totalSeconds * 0.1 {
            return theme.color(.error)
        } else if remaining <= totalSeconds * 0.25 {
            return theme.color(.warning)
        }
        return theme.color(.interactive)
    }

    private var formattedTime: String {
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if remaining > 0 {
                    remaining -= 1
                } else {
                    stopTimer()
                    onComplete?()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Public Controls

    public func start() -> PrismCountdownTimer {
        var copy = self
        copy._isRunning = State(initialValue: true)
        return copy
    }
}
