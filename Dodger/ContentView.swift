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

                if gameState.isGameOver {
                    gameOverOverlay(in: geometry.size)
                }
            }
            .onAppear {
                if scene == nil {
                    scene = GameScene(size: geometry.size, gameState: gameState)
                }
            }
            .onChange(of: geometry.size) { newSize in
                scene?.size = newSize
            }
        }
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

    private func restartGame(with size: CGSize) {
        gameState.reset()
        scene = GameScene(size: size, gameState: gameState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
