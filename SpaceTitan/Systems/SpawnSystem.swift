import SpriteKit
import GameplayKit

class SpawnSystem {
    weak var scene: GameScene?

    private let positionDistX: GKRandomDistribution
    private let positionDistY: GKRandomDistribution
    private let tierDist: GKRandomDistribution
    private let durationJitterDist: GKRandomDistribution

    private let sceneSize: CGSize
    private let margin: CGFloat = 70

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        let w = Int(sceneSize.width)
        let h = Int(sceneSize.height)
        let m = 70

        positionDistX = GKRandomDistribution(lowestValue: m, highestValue: max(m + 1, w - m))
        positionDistY = GKGaussianDistribution(lowestValue: m, highestValue: max(m + 1, h - m))
        tierDist = GKRandomDistribution(lowestValue: 1, highestValue: 10)
        durationJitterDist = GKRandomDistribution(lowestValue: 90, highestValue: 110)
    }

    // MARK: - Control

    func startSpawning(with params: DifficultyParameters) {
        scene?.removeAction(forKey: "spawnLoop")
        // Spawn one immediately, then repeat
        spawnTick(params: params)
        let wait = SKAction.wait(forDuration: params.spawnInterval)
        let spawn = SKAction.run { [weak self] in
            self?.spawnTick(params: params)
        }
        let loop = SKAction.repeatForever(SKAction.sequence([wait, spawn]))
        scene?.run(loop, withKey: "spawnLoop")
    }

    func stopSpawning() {
        scene?.removeAction(forKey: "spawnLoop")
    }

    // MARK: - Private

    private func spawnTick(params: DifficultyParameters) {
        guard let scene else { return }
        guard scene.activeShips.count < params.maxShipsOnScreen else { return }
        guard scene.waveShipsTotal < params.shipsPerWave else {
            stopSpawning()
            return
        }

        let tier = selectTier(level: scene.difficultyManager.currentLevel)
        let jitter = Double(durationJitterDist.nextInt()) / 100.0
        let duration = params.countdownDuration * jitter
        let ship = SpaceshipNode(tier: tier,
                                 countdownDuration: duration,
                                 speedMultiplier: CGFloat(params.speedMultiplier))

        let x = CGFloat(positionDistX.nextInt())
        let y = CGFloat(positionDistY.nextInt())
        ship.position = CGPoint(x: x, y: y)
        ship.delegate = scene

        scene.registerActiveShip(ship)
        scene.addChild(ship)
        ship.startCountdown()
        scene.waveShipsTotal += 1
    }

    private func selectTier(level: Int) -> ShipTier {
        let roll = tierDist.nextInt()
        switch level {
        case 1...3:
            return .scout
        case 4...8:
            return roll <= 7 ? .scout : .fighter
        default:
            if roll <= 4 { return .scout }
            if roll <= 8 { return .fighter }
            return .bomber
        }
    }
}
