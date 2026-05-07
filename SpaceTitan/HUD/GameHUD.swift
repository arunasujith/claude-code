import SwiftUI
import Combine

@MainActor
class GameHUDViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var level: Int = 1
    @Published var isPaused: Bool = false
    @Published var levelCompleteMessage: String? = nil

    weak var scene: GameScene?

    private var cancellable: AnyCancellable?

    init(scene: GameScene) {
        self.scene = scene
        score = ScoreManager.shared.currentScore
        cancellable = NotificationCenter.default
            .publisher(for: ScoreManager.scoreDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.score = ScoreManager.shared.currentScore
            }
    }

    func showLevelComplete(level: Int) {
        levelCompleteMessage = "LEVEL \(level) CLEAR!"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            self.levelCompleteMessage = nil
        }
    }
}

struct GameHUDView: View {
    @ObservedObject var viewModel: GameHUDViewModel

    var body: some View {
        ZStack {
            VStack {
                topBar
                Spacer()
            }

            if let message = viewModel.levelCompleteMessage {
                levelCompleteOverlay(message: message)
            }
        }
    }

    private var topBar: some View {
        HStack {
            scoreView
            Spacer()
            levelView
            Spacer()
            livesView
            pauseButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var scoreView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("SCORE")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.gray)
            Text("\(viewModel.score)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private var levelView: some View {
        VStack(spacing: 2) {
            Text("LEVEL")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.gray)
            Text("\(viewModel.level)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
        }
    }

    private var livesView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < viewModel.lives ? "heart.fill" : "heart")
                    .foregroundColor(i < viewModel.lives ? .red : .gray)
                    .font(.system(size: 16))
            }
        }
    }

    private var pauseButton: some View {
        Button {
            if viewModel.isPaused {
                viewModel.scene?.resumeGame()
            } else {
                viewModel.scene?.pauseGame()
            }
        } label: {
            Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
        }
        .padding(.leading, 8)
    }

    private func levelCompleteOverlay(message: String) -> some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .shadow(color: .orange, radius: 8)
            Text("BONUS +\(viewModel.level * 500)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(), value: viewModel.levelCompleteMessage)
    }
}
