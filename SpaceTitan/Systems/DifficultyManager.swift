import Foundation

struct DifficultyParameters {
    let maxShipsOnScreen: Int
    let countdownDuration: TimeInterval
    let spawnInterval: TimeInterval
    let speedMultiplier: Double
    let shipsPerWave: Int
    let pointsPerShip: Int
}

class DifficultyManager {
    private(set) var currentLevel: Int = 1

    func parameters(for level: Int) -> DifficultyParameters {
        switch level {
        case 1:
            return DifficultyParameters(maxShipsOnScreen: 2, countdownDuration: 5.0,
                                        spawnInterval: 3.0, speedMultiplier: 1.0,
                                        shipsPerWave: 5, pointsPerShip: 100)
        case 2:
            return DifficultyParameters(maxShipsOnScreen: 3, countdownDuration: 4.5,
                                        spawnInterval: 2.5, speedMultiplier: 1.0,
                                        shipsPerWave: 6, pointsPerShip: 150)
        case 3...4:
            return DifficultyParameters(maxShipsOnScreen: 3, countdownDuration: 4.0,
                                        spawnInterval: 2.2, speedMultiplier: 1.1,
                                        shipsPerWave: 7, pointsPerShip: 200)
        case 5...7:
            return DifficultyParameters(maxShipsOnScreen: 4, countdownDuration: 3.5,
                                        spawnInterval: 2.0, speedMultiplier: 1.2,
                                        shipsPerWave: 8, pointsPerShip: 250)
        case 8...11:
            return DifficultyParameters(maxShipsOnScreen: 5, countdownDuration: 3.0,
                                        spawnInterval: 1.8, speedMultiplier: 1.3,
                                        shipsPerWave: 10, pointsPerShip: 300)
        case 12...14:
            return DifficultyParameters(maxShipsOnScreen: 6, countdownDuration: 2.5,
                                        spawnInterval: 1.5, speedMultiplier: 1.5,
                                        shipsPerWave: 12, pointsPerShip: 400)
        default:
            return DifficultyParameters(maxShipsOnScreen: 7, countdownDuration: 2.0,
                                        spawnInterval: 1.2, speedMultiplier: 1.8,
                                        shipsPerWave: 15, pointsPerShip: 500)
        }
    }

    func currentParameters() -> DifficultyParameters {
        parameters(for: currentLevel)
    }

    func advance() {
        currentLevel += 1
    }

    func reset() {
        currentLevel = 1
    }
}
