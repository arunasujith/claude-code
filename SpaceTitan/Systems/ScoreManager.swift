import Foundation

class ScoreManager {
    static let shared = ScoreManager()

    static let scoreDidChange = Notification.Name("ScoreManager.scoreDidChange")

    private let highScoreKey = "SpaceTitan.highScore"

    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0

    private init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func addPoints(_ points: Int) {
        currentScore += points
        if currentScore > highScore {
            highScore = currentScore
        }
        NotificationCenter.default.post(name: ScoreManager.scoreDidChange, object: self)
    }

    func applyLevelBonus(level: Int) {
        addPoints(level * 500)
    }

    func resetCurrentScore() {
        currentScore = 0
        NotificationCenter.default.post(name: ScoreManager.scoreDidChange, object: self)
    }

    func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: highScoreKey)
    }
}
