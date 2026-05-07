import SpriteKit

class ExplosionNode: SKNode {
    private let emitter: SKEmitterNode

    override init() {
        emitter = ExplosionNode.buildEmitter()
        super.init()
        addChild(emitter)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    func play() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
    }

    private static func buildEmitter() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate = 200
        e.numParticlesToEmit = 80
        e.particleLifetime = 0.8
        e.particleLifetimeRange = 0.4
        e.particleSpeed = 150
        e.particleSpeedRange = 80
        e.emissionAngle = 0
        e.emissionAngleRange = .pi * 2
        e.particleAlpha = 1.0
        e.particleAlphaRange = 0.3
        e.particleAlphaSpeed = -1.2
        e.particleScale = 0.15
        e.particleScaleRange = 0.1
        e.particleScaleSpeed = -0.1
        e.particleColor = .orange
        e.particleColorBlendFactor = 1.0
        e.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [UIColor.yellow, UIColor.orange, UIColor.red, UIColor.gray],
            times: [0, 0.2, 0.5, 1.0]
        )
        e.particleBlendMode = .add
        return e
    }
}
