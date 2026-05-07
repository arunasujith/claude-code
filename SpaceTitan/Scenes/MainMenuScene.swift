import SpriteKit

class MainMenuScene: SKScene {

    weak var gameViewController: GameViewController?

    private var titleLabel: SKLabelNode!
    private var tapLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        setupBackground()
        setupLabels()
        startPulse(on: tapLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        transitionToGame()
    }

    // MARK: - Setup

    private func setupBackground() {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)

        let e = SKEmitterNode()
        e.particleBirthRate = 3
        e.particleLifetime = 14
        e.particleLifetimeRange = 4
        e.particleSpeed = 20
        e.particleSpeedRange = 10
        e.emissionAngle = -.pi / 2
        e.emissionAngleRange = 0.2
        e.particleAlpha = 0.8
        e.particleAlphaRange = 0.5
        e.particleScale = 0.05
        e.particleScaleRange = 0.04
        e.particleColor = .white
        e.particleBlendMode = .add
        e.position = CGPoint(x: size.width / 2, y: size.height + 10)
        e.particlePositionRange = CGVector(dx: size.width, dy: 0)
        e.zPosition = -10
        addChild(e)
    }

    private func setupLabels() {
        titleLabel = SKLabelNode(text: "SPACE TITAN")
        titleLabel.fontName = "Helvetica-Black"
        titleLabel.fontSize = 52
        titleLabel.fontColor = .cyan
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        titleLabel.zPosition = 1
        addChild(titleLabel)

        let subtitle = SKLabelNode(text: "TAP SHIPS BEFORE THEY ESCAPE")
        subtitle.fontName = "Helvetica"
        subtitle.fontSize = 16
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        subtitle.zPosition = 1
        addChild(subtitle)

        tapLabel = SKLabelNode(text: "TAP ANYWHERE TO PLAY")
        tapLabel.fontName = "Helvetica-Bold"
        tapLabel.fontSize = 22
        tapLabel.fontColor = .white
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        tapLabel.zPosition = 1
        addChild(tapLabel)

        let hs = ScoreManager.shared.highScore
        highScoreLabel = SKLabelNode(text: "BEST: \(hs)")
        highScoreLabel.fontName = "Helvetica"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        highScoreLabel.zPosition = 1
        addChild(highScoreLabel)
    }

    private func startPulse(on node: SKNode) {
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7)
        ]))
        node.run(pulse, withKey: "pulse")
    }

    private func transitionToGame() {
        guard let vc = gameViewController else { return }
        vc.presentGameScene()
    }
}
