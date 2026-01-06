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

        var color: Color {
            switch self {
            case .mint: return .mint
            case .blue: return .cyan
            case .purple: return .purple
            case .orange: return .orange
            case .white: return .white
            }
        }

        var skColor: SKColor {
            SKColor(color)
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

        var color: Color {
            switch self {
            case .midnight: return Color(red: 0.06, green: 0.07, blue: 0.1)
            case .nebula: return Color(red: 0.06, green: 0.1, blue: 0.2)
            case .charcoal: return Color(red: 0.12, green: 0.12, blue: 0.14)
            case .aurora: return Color(red: 0.05, green: 0.16, blue: 0.16)
            case .graphite: return Color(red: 0.08, green: 0.08, blue: 0.12)
            }
        }

        var skColor: SKColor {
            SKColor(color)
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
