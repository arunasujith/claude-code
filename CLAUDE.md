# Space Titan — Claude Code Context

## Project
iOS 2D arcade game built with SpriteKit + GameplayKit + SwiftUI.

## Tech Stack
- Language: Swift 5.9+, iOS 16.0+
- Game engine: SpriteKit
- AI/randomization: GameplayKit (GKStateMachine, GKRandomDistribution, GKGaussianDistribution)
- HUD: SwiftUI via UIHostingController
- Audio: AVAudioPlayer (BGM) + SKAction (SFX)
- Persistence: UserDefaults
- NO third-party dependencies

## Architecture
- `Nodes/` — SKNode subclasses (SpaceshipNode, ExplosionNode)
- `Systems/` — pure Swift logic, no SKNode dependency (DifficultyManager, SpawnSystem, ScoreManager)
- `States/` — GKState subclasses for the game's GKStateMachine
- `Scenes/` — SKScene subclasses (MainMenuScene, GameScene, GameOverScene)
- `HUD/` — SwiftUI GameHUDView + GameHUDViewModel
- `Audio/` — AudioManager (AVAudioPlayer wrapper)

## Key Rules
- Use GKStateMachine for game state; never raw booleans
- All random values via GameplayKit distributions (not arc4random or Swift.random in game logic)
- No force-unwraps (!) in game-critical paths (SpawnSystem, DifficultyManager, SpaceshipNode)
- All SKNode subclasses must handle removal from parent in their escape/destroy paths
- Audio loading always wrapped in guard/do-catch — missing files must never crash
- SpawnSystem uses SKAction-based loop (not Timer) so scene.isPaused correctly pauses spawning

## Bundle ID
com.spacetitan.game

## Deployment Target
iOS 16.0, iPhone only (landscape)
