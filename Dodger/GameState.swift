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

    private let bestScoreKey = "bestScore"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
    }

    func reset() {
        score = 0
        isGameOver = false
    }

    func updateScore(_ newScore: Int) {
        score = newScore
    }

    func triggerGameOver() {
        isGameOver = true
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        }
    }
}
