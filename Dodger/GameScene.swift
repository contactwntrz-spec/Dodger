//
//  GameScene.swift
//  Dodger
//
//  Created by Tobias Ruß on 06.01.26.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum PhysicsCategory {
        static let player: UInt32 = 0x1 << 0
        static let obstacle: UInt32 = 0x1 << 1
    }

    private enum Constants {
        static let playerSize = CGSize(width: 50, height: 30)
        static let playerBottomInsetRatio: CGFloat = 0.12
        static let obstacleMinSize: CGFloat = 20
        static let obstacleMaxSize: CGFloat = 50
        static let initialSpawnInterval: TimeInterval = 0.8
        static let minimumSpawnInterval: TimeInterval = 0.35
        static let spawnIntervalDecay: TimeInterval = 0.01
        static let initialFallDuration: TimeInterval = 3.0
        static let minimumFallDuration: TimeInterval = 1.0
        static let fallDurationDecay: TimeInterval = 0.05
        static let scoreTick: TimeInterval = 0.2
        static let obstacleColor = SKColor.systemPink
    }

    private weak var gameState: GameState?

    private var playerNode: SKShapeNode?
    private var lastUpdateTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var scoreAccumulator: TimeInterval = 0

    init(size: CGSize, gameState: GameState) {
        self.gameState = gameState
        super.init(size: size)
        configureScene()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureScene()
    }

    private func configureScene() {
        scaleMode = .resizeFill
        applyTheme()
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        createPlayer()
        applyTheme()
        lastUpdateTime = 0
        spawnTimer = 0
        elapsedTime = 0
        scoreAccumulator = 0
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        updatePlayerPosition(x: playerNode?.position.x)
    }

    func movePlayer(toX xPosition: CGFloat) {
        guard let gameState, gameState.hasStarted, !gameState.isGameOver else { return }
        updatePlayerPosition(x: xPosition)
    }

    private func createPlayer() {
        let player = SKShapeNode(rectOf: Constants.playerSize, cornerRadius: 8)
        player.fillColor = gameState?.playerColorOption.skColor ?? SKColor.systemMint
        player.strokeColor = .clear
        player.name = "player"

        let body = SKPhysicsBody(rectangleOf: Constants.playerSize)
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.obstacle
        player.physicsBody = body

        addChild(player)
        playerNode = player
        updatePlayerPosition(x: size.width / 2)
    }

    func applyTheme() {
        backgroundColor = gameState?.backgroundOption.skColor ?? SKColor.black
        playerNode?.fillColor = gameState?.playerColorOption.skColor ?? SKColor.systemMint
    }

    private func updatePlayerPosition(x: CGFloat?) {
        guard let playerNode else { return }
        let desiredX = x ?? size.width / 2
        let halfWidth = Constants.playerSize.width / 2
        let halfHeight = Constants.playerSize.height / 2
        let clampedX = max(halfWidth, min(size.width - halfWidth, desiredX))
        let yPosition = max(halfHeight, size.height * Constants.playerBottomInsetRatio)
        playerNode.position = CGPoint(x: clampedX, y: yPosition)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let gameState,
              gameState.hasStarted,
              !gameState.isGameOver,
              !gameState.isPaused else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        elapsedTime += deltaTime
        spawnTimer += deltaTime
        scoreAccumulator += deltaTime

        updateScoreIfNeeded()
        spawnObstacleIfNeeded()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        movePlayer(toX: touch.location(in: self).x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        movePlayer(toX: touch.location(in: self).x)
    }

    private func updateScoreIfNeeded() {
        guard let gameState else { return }
        while scoreAccumulator >= Constants.scoreTick {
            scoreAccumulator -= Constants.scoreTick
            gameState.updateScore(gameState.score + 1)
        }
    }

    private func spawnObstacleIfNeeded() {
        let currentInterval = max(
            Constants.minimumSpawnInterval,
            Constants.initialSpawnInterval - elapsedTime * Constants.spawnIntervalDecay
        )

        guard spawnTimer >= currentInterval else { return }
        spawnTimer = 0
        spawnObstacle()
    }

    private func spawnObstacle() {
        let sizeValue = CGFloat.random(in: Constants.obstacleMinSize...Constants.obstacleMaxSize)
        let obstacleSize = CGSize(width: sizeValue, height: sizeValue)
        let obstacle = SKSpriteNode(color: Constants.obstacleColor, size: obstacleSize)
        obstacle.name = "obstacle"
        obstacle.zPosition = 1

        let body = SKPhysicsBody(rectangleOf: obstacleSize)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.player
        obstacle.physicsBody = body

        let spawnX = CGFloat.random(in: obstacleSize.width / 2...(size.width - obstacleSize.width / 2))
        let spawnY = size.height + obstacleSize.height
        obstacle.position = CGPoint(x: spawnX, y: spawnY)
        addChild(obstacle)

        let fallDuration = max(
            Constants.minimumFallDuration,
            Constants.initialFallDuration - elapsedTime * Constants.fallDurationDecay
        )
        let targetY = -obstacleSize.height
        let moveAction = SKAction.moveTo(y: targetY, duration: fallDuration)
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let gameState, !gameState.isGameOver else { return }

        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if categories == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameState.triggerGameOver()
        }
    }
}
