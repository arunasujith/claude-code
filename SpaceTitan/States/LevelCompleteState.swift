import GameplayKit
import SpriteKit

class LevelCompleteState: GKState {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self || stateClass == GameOverState.self
    }

    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        scene.spawnSystem.stopSpawning()
        scene.scoreManager.applyLevelBonus(level: scene.difficultyManager.currentLevel)
        scene.hudViewModel.showLevelComplete(level: scene.difficultyManager.currentLevel)
        AudioManager.shared.playSFX(named: "level_complete.wav", on: scene)

        scene.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.run { [weak scene] in scene?.advanceToNextLevel() }
        ]), withKey: "levelTransition")
    }

    override func willExit(to nextState: GKState) {
        scene?.removeAction(forKey: "levelTransition")
    }
}
