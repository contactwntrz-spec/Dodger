//
//  GameState.swift
//  Dodger
//
//  Created by Tobias Ruß on 06.01.26.
//

import Foundation
import Combine
import SwiftUI
import SpriteKit

final class GameState: ObservableObject {
    enum PlayerColorOption: String, CaseIterable, Identifiable {
        case mint
        case blue
        case purple
        case orange
        case white

        var id: String { rawValue }

        var name: String {
            switch self {
            case .mint: return "Mint"
            case .blue: return "Ocean"
            case .purple: return "Violet"
            case .orange: return "Sunset"
            case .white: return "Classic"
            }
        }

        var skColor: SKColor {
            switch self {
            case .mint: return SKColor.systemMint
            case .blue: return SKColor.systemCyan
            case .purple: return SKColor.systemPurple
            case .orange: return SKColor.systemOrange
            case .white: return SKColor.white
            }
        }

        var color: Color {
            Color(skColor)
        }
    }

    enum BackgroundOption: String, CaseIterable, Identifiable {
        case midnight
        case nebula
        case charcoal
        case aurora
        case graphite

        var id: String { rawValue }

        var name: String {
            switch self {
            case .midnight: return "Midnight"
            case .nebula: return "Nebula"
            case .charcoal: return "Charcoal"
            case .aurora: return "Aurora"
            case .graphite: return "Graphite"
            }
        }

        var skColor: SKColor {
            switch self {
            case .midnight: return SKColor(red: 0.06, green: 0.07, blue: 0.1, alpha: 1.0)
            case .nebula: return SKColor(red: 0.06, green: 0.1, blue: 0.2, alpha: 1.0)
            case .charcoal: return SKColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
            case .aurora: return SKColor(red: 0.05, green: 0.16, blue: 0.16, alpha: 1.0)
            case .graphite: return SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
            }
        }

        var color: Color {
            Color(skColor)
        }
    }

    @Published var score: Int = 0
    @Published var bestScore: Int
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var hasStarted: Bool = false
    @Published var playerColorOption: PlayerColorOption
    @Published var backgroundOption: BackgroundOption

    private let bestScoreKey = "bestScore"
    private let playerColorKey = "playerColorOption"
    private let backgroundKey = "backgroundOption"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
        if let savedPlayer = UserDefaults.standard.string(forKey: playerColorKey),
           let option = PlayerColorOption(rawValue: savedPlayer) {
            playerColorOption = option
        } else {
            playerColorOption = .mint
        }

        if let savedBackground = UserDefaults.standard.string(forKey: backgroundKey),
           let option = BackgroundOption(rawValue: savedBackground) {
            backgroundOption = option
        } else {
            backgroundOption = .midnight
        }
    }

    func setPlayerColor(_ option: PlayerColorOption) {
        playerColorOption = option
        UserDefaults.standard.set(option.rawValue, forKey: playerColorKey)
    }

    func setBackground(_ option: BackgroundOption) {
        backgroundOption = option
        UserDefaults.standard.set(option.rawValue, forKey: backgroundKey)
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
