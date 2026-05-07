import SpriteKit
import GameplayKit
import SwiftUI

class GameScene: SKScene {

    // MARK: - Systems
    let difficultyManager = DifficultyManager()
    let scoreManager = ScoreManager.shared
    private(set) lazy var spawnSystem = SpawnSystem(sceneSize: size)

    // MARK: - State Machine
    private(set) var stateMachine: GKStateMachine!

    // MARK: - HUD
    private(set) var hudViewModel: GameHUDViewModel!
    private var hudHostingController: UIHostingController<GameHUDView>?

    // MARK: - Game State
    weak var parentViewController: UIViewController?
    private(set) var lives: Int = 3
    private(set) var activeShips: Set<SpaceshipNode> = []

    // Wave tracking
    var waveShipsTotal: Int = 0
    private var waveShipsDestroyed: Int = 0
    private var waveShipsEscaped: Int = 0

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        scoreManager.resetCurrentScore()
        difficultyManager.reset()

        hudViewModel = GameHUDViewModel(scene: self)
        hudViewModel.lives = lives
        hudViewModel.level = difficultyManager.currentLevel

        spawnSystem.scene = self

        setupBackground()

        let menu        = MenuState(scene: self)
        let playing     = PlayingState(scene: self)
        let paused      = PausedState(scene: self)
        let levelDone   = LevelCompleteState(scene: self)
        let gameOver    = GameOverState(scene: self)
        stateMachine = GKStateMachine(states: [menu, playing, paused, levelDone, gameOver])

        setupHUD(in: view)

        stateMachine.enter(PlayingState.self)
    }

    override func willMove(from view: SKView) {
        teardownHUD()
        spawnSystem.stopSpawning()
    }

    override func update(_ currentTime: TimeInterval) {
        stateMachine.update(deltaTime: 1.0 / 60.0)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.currentState is PlayingState else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        for node in tappedNodes {
            var candidate: SKNode? = node
            while let c = candidate {
                if let ship = c as? SpaceshipNode, ship.isAlive {
                    ship.destroy(animated: true)
                    AudioManager.shared.playSFX(named: "destroy.wav", on: self)
                    return
                }
                candidate = c.parent
            }
        }
    }

    // MARK: - Ship Management

    func registerActiveShip(_ ship: SpaceshipNode) {
        activeShips.insert(ship)
    }

    func removeActiveShip(_ ship: SpaceshipNode) {
        activeShips.remove(ship)
    }

    // MARK: - Game Flow

    func pauseGame() {
        stateMachine.enter(PausedState.self)
    }

    func resumeGame() {
        stateMachine.enter(PlayingState.self)
    }

    func advanceToNextLevel() {
        difficultyManager.advance()
        waveShipsTotal = 0
        waveShipsDestroyed = 0
        waveShipsEscaped = 0
        hudViewModel.level = difficultyManager.currentLevel
        stateMachine.enter(PlayingState.self)
    }

    func endGame() {
        stateMachine.enter(GameOverState.self)
    }

    // MARK: - Life Management

    func loseLife() {
        lives -= 1
        hudViewModel.lives = lives

        // Screen shake
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 4, duration: 0.05),
            SKAction.moveBy(x: 8, y: -8, duration: 0.05),
            SKAction.moveBy(x: -8, y: 4, duration: 0.05),
            SKAction.moveBy(x: 8, y: 0, duration: 0.05)
        ])
        run(shake)

        AudioManager.shared.playSFX(named: "life_lost.wav", on: self)

        if lives <= 0 {
            stateMachine.enter(GameOverState.self)
        }
    }

    // MARK: - Wave Completion

    func checkWaveCompletion() {
        let params = difficultyManager.currentParameters()
        let resolved = waveShipsDestroyed + waveShipsEscaped
        guard waveShipsTotal >= params.shipsPerWave,
              activeShips.isEmpty,
              resolved >= params.shipsPerWave else { return }
        stateMachine.enter(LevelCompleteState.self)
    }

    // MARK: - Background

    private func setupBackground() {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)

        let starfield = buildStarfield()
        starfield.zPosition = -10
        addChild(starfield)
    }

    private func buildStarfield() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate = 3
        e.particleLifetime = 12
        e.particleLifetimeRange = 4
        e.particleSpeed = 20
        e.particleSpeedRange = 10
        e.emissionAngle = -.pi / 2
        e.emissionAngleRange = 0.2
        e.particleAlpha = 0.8
        e.particleAlphaRange = 0.5
        e.particleScale = 0.05
        e.particleScaleRange = 0.05
        e.particleColor = .white
        e.particleBlendMode = .add
        e.position = CGPoint(x: size.width / 2, y: size.height + 20)
        e.particlePositionRange = CGVector(dx: size.width, dy: 0)
        return e
    }

    // MARK: - HUD

    private func setupHUD(in view: SKView) {
        guard let vc = parentViewController else { return }
        let hudView = GameHUDView(viewModel: hudViewModel)
        let hosting = UIHostingController(rootView: hudView)
        hosting.view.backgroundColor = .clear
        hosting.view.isUserInteractionEnabled = true
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: vc)
        hudHostingController = hosting
    }

    private func teardownHUD() {
        hudHostingController?.willMove(toParent: nil)
        hudHostingController?.view.removeFromSuperview()
        hudHostingController?.removeFromParent()
        hudHostingController = nil
    }
}

// MARK: - SpaceshipNodeDelegate

extension GameScene: SpaceshipNodeDelegate {
    func shipWasDestroyed(_ ship: SpaceshipNode) {
        waveShipsDestroyed += 1
        removeActiveShip(ship)

        let params = difficultyManager.currentParameters()
        let bonus = ship.pointValue * params.pointsPerShip / 100
        scoreManager.addPoints(bonus)

        // Score pop label
        let pop = SKLabelNode(text: "+\(bonus)")
        pop.fontName = "Helvetica-Bold"
        pop.fontSize = 18
        pop.fontColor = .yellow
        pop.position = ship.position
        pop.zPosition = 10
        addChild(pop)
        pop.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))

        checkWaveCompletion()
    }

    func shipEscaped(_ ship: SpaceshipNode) {
        waveShipsEscaped += 1
        removeActiveShip(ship)
        loseLife()
        checkWaveCompletion()
    }
}
