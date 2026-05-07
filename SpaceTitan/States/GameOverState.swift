import GameplayKit
import SpriteKit

class GameOverState: GKState {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }

    override func didEnter(from previousState: GKState?) {
        guard let scene else { return }
        scene.spawnSystem.stopSpawning()
        AudioManager.shared.stopBackgroundMusic()
        scene.scoreManager.saveHighScore()
        AudioManager.shared.playSFX(named: "game_over.wav", on: scene)

        for ship in scene.activeShips {
            ship.removeFromParent()
        }
        scene.activeShips.removeAll()

        scene.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak scene] in
                guard let scene, let view = scene.view else { return }
                let gameOver = GameOverScene(size: view.bounds.size,
                                            score: scene.scoreManager.currentScore)
                gameOver.scaleMode = .resizeFill
                view.presentScene(gameOver, transition: SKTransition.crossFade(withDuration: 0.5))
            }
        ]))
    }
}
