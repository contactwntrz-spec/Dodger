//
//  GameState.swift
//  Dodger
//
//  Created by Tobias Ruß on 06.01.26.
//

import Foundation
import Combine

final class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var bestScore: Int
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var hasStarted: Bool = false

    private let bestScoreKey = "bestScore"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
    }

    func reset() {
        score = 0
        isGameOver = false
        isPaused = false
        hasStarted = true
    }

    func updateScore(_ newScore: Int) {
        score = newScore
    }

    func setPaused(_ paused: Bool) {
        guard !isGameOver else { return }
        isPaused = paused
    }

    func startGame() {
        hasStarted = true
        isPaused = false
        isGameOver = false
        score = 0
    }

    func triggerGameOver() {
        isGameOver = true
        isPaused = false
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        }
    }
}
