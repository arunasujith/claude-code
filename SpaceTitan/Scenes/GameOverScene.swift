import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int
    private let isHighScore: Bool

    init(size: CGSize, score: Int) {
        self.finalScore = score
        self.isHighScore = score >= ScoreManager.shared.highScore && score > 0
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        returnToMenu()
    }

    // MARK: - Setup

    private func setupBackground() {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)
    }

    private func setupUI() {
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "Helvetica-Black"
        gameOverLabel.fontSize = 52
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(gameOverLabel)

        if isHighScore {
            let newRecord = SKLabelNode(text: "NEW HIGH SCORE!")
            newRecord.fontName = "Helvetica-Bold"
            newRecord.fontSize = 20
            newRecord.fontColor = .yellow
            newRecord.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
            addChild(newRecord)
            let glow = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ]))
            newRecord.run(glow)
        }

        let scoreLabel = SKLabelNode(text: "SCORE")
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 14
        scoreLabel.fontColor = UIColor(white: 0.6, alpha: 1)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        addChild(scoreLabel)

        let scoreValue = SKLabelNode(text: "\(finalScore)")
        scoreValue.fontName = "Helvetica-Black"
        scoreValue.fontSize = 42
        scoreValue.fontColor = .white
        scoreValue.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        addChild(scoreValue)

        let highScoreLabel = SKLabelNode(text: "BEST: \(ScoreManager.shared.highScore)")
        highScoreLabel.fontName = "Helvetica"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        addChild(highScoreLabel)

        let replayLabel = SKLabelNode(text: "TAP TO PLAY AGAIN")
        replayLabel.fontName = "Helvetica-Bold"
        replayLabel.fontSize = 20
        replayLabel.fontColor = .cyan
        replayLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        addChild(replayLabel)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7)
        ]))
        replayLabel.run(pulse)
    }

    private func returnToMenu() {
        guard let view else { return }
        let menu = MainMenuScene(size: view.bounds.size)
        menu.scaleMode = .resizeFill
        // Re-attach the gameViewController reference
        if let vc = view.window?.rootViewController as? GameViewController {
            menu.gameViewController = vc
        }
        view.presentScene(menu, transition: SKTransition.fade(withDuration: 0.5))
    }
}
