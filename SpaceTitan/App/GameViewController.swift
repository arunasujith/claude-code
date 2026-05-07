import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        presentMainMenu()
    }

    func presentMainMenu() {
        guard let skView = view as? SKView else { return }
        let menu = MainMenuScene(size: view.bounds.size)
        menu.scaleMode = .resizeFill
        menu.gameViewController = self
        skView.presentScene(menu, transition: SKTransition.fade(withDuration: 0.4))
    }

    func presentGameScene() {
        guard let skView = view as? SKView else { return }
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.parentViewController = self
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
