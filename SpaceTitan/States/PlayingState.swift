import GameplayKit

class PlayingState: GKState {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PausedState.self
            || stateClass == LevelCompleteState.self
            || stateClass == GameOverState.self
    }

    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        scene.isPaused = false
        let params = scene.difficultyManager.currentParameters()
        scene.spawnSystem.startSpawning(with: params)
        if previousState == nil || previousState is MenuState {
            AudioManager.shared.playBackgroundMusic()
        } else if previousState is PausedState {
            AudioManager.shared.resumeBackgroundMusic()
        }
    }

    override func willExit(to nextState: GKState) {
        scene?.spawnSystem.stopSpawning()
    }

    override func update(deltaTime seconds: TimeInterval) {}
}
