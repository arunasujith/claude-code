import GameplayKit

class PausedState: GKState {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.isPaused = true
        scene?.hudViewModel.isPaused = true
        AudioManager.shared.pauseBackgroundMusic()
    }

    override func willExit(to nextState: GKState) {
        scene?.isPaused = false
        scene?.hudViewModel.isPaused = false
    }
}
