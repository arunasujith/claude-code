import GameplayKit

class MenuState: GKState {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self
    }

    override func didEnter(from previousState: GKState?) {
        scene?.spawnSystem.stopSpawning()
    }

    override func willExit(to nextState: GKState) {}
}
