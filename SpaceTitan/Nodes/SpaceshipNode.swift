import SpriteKit
import UIKit

protocol SpaceshipNodeDelegate: AnyObject {
    func shipWasDestroyed(_ ship: SpaceshipNode)
    func shipEscaped(_ ship: SpaceshipNode)
}

enum ShipTier: Int {
    case scout = 1
    case fighter = 2
    case bomber = 3

    var pointValue: Int {
        switch self {
        case .scout:   return 100
        case .fighter: return 200
        case .bomber:  return 350
        }
    }

    var scale: CGFloat {
        switch self {
        case .scout:   return 1.0
        case .fighter: return 1.3
        case .bomber:  return 1.6
        }
    }
}

class SpaceshipNode: SKNode {
    let tier: ShipTier
    let countdownDuration: TimeInterval
    let pointValue: Int

    weak var delegate: SpaceshipNodeDelegate?

    private(set) var isAlive: Bool = true

    private let bodySprite: SKSpriteNode
    private let ringNode: SKShapeNode
    private let timerLabel: SKLabelNode
    private let ringRadius: CGFloat = 36

    init(tier: ShipTier, countdownDuration: TimeInterval, speedMultiplier: CGFloat) {
        self.tier = tier
        self.countdownDuration = countdownDuration
        self.pointValue = tier.pointValue

        bodySprite = SpaceshipNode.buildBody(for: tier, speedMultiplier: speedMultiplier)
        ringNode = SpaceshipNode.buildRingNode(radius: 36)
        timerLabel = SpaceshipNode.buildTimerLabel()

        super.init()

        addChild(ringNode)
        addChild(bodySprite)
        addChild(timerLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Public API

    func startCountdown() {
        let countdownAction = SKAction.customAction(withDuration: countdownDuration) { [weak self] _, elapsed in
            guard let self, self.isAlive else { return }
            let fraction = CGFloat(1.0 - elapsed / self.countdownDuration)
            self.updateRing(fraction: fraction)
            let remaining = Int(ceil(self.countdownDuration - elapsed))
            self.timerLabel.text = "\(remaining)"

            if fraction < 0.25 && self.action(forKey: "pulse") == nil {
                self.run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: 1.08, duration: 0.15),
                        SKAction.scale(to: 1.0,  duration: 0.15)
                    ])
                ), withKey: "pulse")
            }
        }

        let sequence = SKAction.sequence([
            countdownAction,
            SKAction.run { [weak self] in self?.timerExpired() }
        ])
        run(sequence, withKey: "countdown")
    }

    func destroy(animated: Bool) {
        guard isAlive else { return }
        isAlive = false
        removeAction(forKey: "countdown")
        removeAction(forKey: "pulse")

        if animated {
            let explosion = ExplosionNode()
            explosion.position = position
            parent?.addChild(explosion)
            explosion.play()
        }

        delegate?.shipWasDestroyed(self)
        run(SKAction.removeFromParent())
    }

    func freeze() {
        isPaused = true
    }

    func unfreeze() {
        isPaused = false
    }

    // MARK: - Private

    private func updateRing(fraction: CGFloat) {
        let path = arcPath(fraction: max(0, fraction), radius: ringRadius)
        ringNode.path = path
        ringNode.strokeColor = ringColor(for: fraction)
    }

    private func arcPath(fraction: CGFloat, radius: CGFloat) -> CGPath {
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = startAngle + (2 * .pi * fraction)
        let bezier = UIBezierPath(arcCenter: .zero,
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true)
        return bezier.cgPath
    }

    private func ringColor(for fraction: CGFloat) -> UIColor {
        if fraction > 0.5 {
            return UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        } else if fraction > 0.25 {
            return UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1)
        } else {
            return UIColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1)
        }
    }

    private func timerExpired() {
        guard isAlive else { return }
        isAlive = false
        delegate?.shipEscaped(self)
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Static Builders

    private static func buildBody(for tier: ShipTier, speedMultiplier: CGFloat) -> SKSpriteNode {
        let textureName = "spaceship_tier\(tier.rawValue)"
        let sprite = SKSpriteNode(imageNamed: textureName)

        // Fallback to procedural triangle if texture is missing
        if sprite.size == .zero || sprite.texture == nil {
            sprite.size = CGSize(width: 40 * tier.scale, height: 40 * tier.scale)
            let shape = buildProceduralShip(for: tier)
            sprite.addChild(shape)
        } else {
            sprite.size = CGSize(width: sprite.size.width * tier.scale,
                                 height: sprite.size.height * tier.scale)
        }

        return sprite
    }

    private static func buildProceduralShip(for tier: ShipTier) -> SKShapeNode {
        let size: CGFloat = 30 * tier.scale
        let path = UIBezierPath()
        path.move(to:    CGPoint(x: 0,        y:  size / 2))
        path.addLine(to: CGPoint(x:  size / 2, y: -size / 2))
        path.addLine(to: CGPoint(x: -size / 2, y: -size / 2))
        path.close()

        let shape = SKShapeNode(path: path.cgPath)
        shape.fillColor = tierColor(for: tier)
        shape.strokeColor = .white
        shape.lineWidth = 1.5
        return shape
    }

    private static func tierColor(for tier: ShipTier) -> UIColor {
        switch tier {
        case .scout:   return UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1)
        case .fighter: return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1)
        case .bomber:  return UIColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 1)
        }
    }

    private static func buildRingNode(radius: CGFloat) -> SKShapeNode {
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = startAngle + 2 * .pi
        let path = UIBezierPath(arcCenter: .zero, radius: radius,
                                startAngle: startAngle, endAngle: endAngle,
                                clockwise: true)
        let ring = SKShapeNode(path: path.cgPath)
        ring.strokeColor = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        ring.lineWidth = 3
        ring.fillColor = .clear
        return ring
    }

    private static func buildTimerLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        return label
    }
}
