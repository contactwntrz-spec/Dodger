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
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    scene.movePlayer(toX: value.location.x)
                                }
                        )
                } else {
                    Color.black
                        .ignoresSafeArea()
                }

                if gameState.hasStarted {
                    scoreOverlay
                    pauseButtonOverlay
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
            }
            .onChange(of: geometry.size) { _, newSize in
                scene?.size = newSize
            }
            .onChange(of: gameState.isPaused) { _, paused in
                scene?.isPaused = paused
            }
            .onChange(of: gameState.isGameOver) { _, isGameOver in
                if isGameOver {
                    scene?.isPaused = true
                }
            }
        }
    }

    private var scoreOverlay: some View {
        VStack {
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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    private var pauseButtonOverlay: some View {
        ZStack(alignment: .topTrailing) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
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

                Button("Restart") {
                    restartGame(with: size)
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(Capsule())
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

                Button("Start") {
                    startGame(with: size)
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(Capsule())
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
            }
        }
    }

    private func startGame(with size: CGSize) {
        gameState.startGame()
        scene = GameScene(size: size, gameState: gameState)
    }

    private func restartGame(with size: CGSize) {
        gameState.reset()
        scene = GameScene(size: size, gameState: gameState)
    }

    private func togglePause() {
        gameState.setPaused(!gameState.isPaused)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
