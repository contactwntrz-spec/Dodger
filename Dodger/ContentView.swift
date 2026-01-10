//
//  ContentView.swift
//  Dodger
//
//  Created by Tobias Ruß on 06.01.26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var scene: GameScene?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                        .overlay(alignment: .top) {
                            if gameState.hasStarted {
                                scoreOverlay
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if gameState.hasStarted {
                                pauseButton
                            }
                        }
                } else {
                    Color.black
                        .ignoresSafeArea()
                }

                if !gameState.hasStarted {
                    startOverlay(in: geometry.size)
                } else if gameState.isGameOver {
                    gameOverOverlay(in: geometry.size)
                } else if gameState.isPaused {
                    pauseOverlay(in: geometry.size)
                }
            }
            .onAppear {
                if scene == nil {
                    scene = GameScene(size: geometry.size, gameState: gameState)
                }
                syncPauseState()
            }
            .onChange(of: geometry.size) { _, newSize in
                scene?.size = newSize
            }
            .onChange(of: gameState.hasStarted) { _, hasStarted in
                syncPauseState()
            }
            .onChange(of: gameState.isPaused) { _, paused in
                syncPauseState()
            }
            .onChange(of: gameState.isGameOver) { _, isGameOver in
                syncPauseState()
            }
            .onChange(of: gameState.playerColorOption) { _, _ in
                scene?.applyTheme()
            }
            .onChange(of: gameState.backgroundOption) { _, _ in
                scene?.applyTheme()
            }
        }
    }

    private var scoreOverlay: some View {
        HStack {
            Text("Score: \(gameState.score)")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Text("Best: \(gameState.bestScore)")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .allowsHitTesting(false)
    }

    private var pauseButton: some View {
        Button(gameState.isPaused ? "Resume" : "Pause") {
            togglePause()
        }
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
        .foregroundStyle(.black)
        .clipShape(Capsule())
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    @ViewBuilder
    private func gameOverOverlay(in size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Score: \(gameState.score)")
                    .font(.title2)
                    .foregroundStyle(.white)

                Text("Best: \(gameState.bestScore)")
                    .font(.title3)
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    Button("Main Menu") {
                        returnToMenu()
                    }
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())

                    Button("Restart") {
                        restartGame(with: size)
                    }
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.85))
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private func startOverlay(in size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Dodger")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Weiche den Hindernissen aus")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))

                HStack(spacing: 12) {
                    menuCard(title: "Highscore", value: "\(gameState.bestScore)")
                    menuCard(title: "Modus", value: "Endlos")
                }

                Button("Start") {
                    startGame(with: size)
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(Capsule())

                settingsPanel(title: "Einstellungen")
            }
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func pauseOverlay(in size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Pause")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Button("Weiter") {
                    togglePause()
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(Capsule())

                settingsPanel(title: "Pause-Einstellungen")
            }
        }
    }

    private func settingsPanel(title: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            selectionRow(
                title: "Spielerfarbe",
                options: GameState.PlayerColorOption.allCases,
                selected: gameState.playerColorOption,
                colorProvider: { $0.color },
                action: { gameState.setPlayerColor($0) }
            )

            selectionRow(
                title: "Hintergrund",
                options: GameState.BackgroundOption.allCases,
                selected: gameState.backgroundOption,
                colorProvider: { $0.color },
                action: { gameState.setBackground($0) }
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func selectionRow<Option: Identifiable & Hashable>(
        title: String,
        options: [Option],
        selected: Option,
        colorProvider: @escaping (Option) -> Color,
        action: @escaping (Option) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 48), spacing: 12)], spacing: 12) {
                ForEach(options, id: \.id) { option in
                    Button {
                        action(option)
                    } label: {
                        Circle()
                            .fill(colorProvider(option))
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: option.id == selected.id ? 3 : 1)
                            )
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func menuCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func startGame(with size: CGSize) {
        gameState.startGame()
        scene = GameScene(size: size, gameState: gameState)
        scene?.applyTheme()
        syncPauseState()
    }

    private func restartGame(with size: CGSize) {
        gameState.reset()
        scene = GameScene(size: size, gameState: gameState)
        scene?.applyTheme()
        syncPauseState()
    }

    private func returnToMenu() {
        gameState.hasStarted = false
        gameState.isGameOver = false
        gameState.isPaused = false
        gameState.score = 0
        syncPauseState()
    }

    private func togglePause() {
        let newValue = !gameState.isPaused
        gameState.setPaused(newValue)
        applyPauseState(newValue)
    }

    private func syncPauseState() {
        let shouldPause = !gameState.hasStarted || gameState.isPaused || gameState.isGameOver
        applyPauseState(shouldPause)
    }

    private func applyPauseState(_ shouldPause: Bool) {
        scene?.isPaused = false
        scene?.speed = shouldPause ? 0 : 1
        scene?.physicsWorld.speed = shouldPause ? 0 : 1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
