//
//  GameScene.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime: TimeInterval = 0
    private let mainCamera = SKCameraNode()
    
    private let levelConfig = LevelConfig.defaultConfig
    private var generatedLevel: GeneratedLevel?
    private var previousPlayerBottomY: CGFloat?
    
    // Walls
    private let wallThickness: CGFloat = 20
    
    var levelSeed: UInt64?
    let cameraOffsetY: CGFloat = 260
    
    // Debug
    private let showDebugGrid = false
    
    // Player Systems
    var player: PlayerEntity?
    var movementSystem = GKComponentSystem(componentClass: MovementSystem.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraSystem.self)
    var stateSystem = GKComponentSystem(componentClass: StateSystem.self)
    
    // Trap Systems
    var blackHoleSystem = GKComponentSystem(componentClass: BlackHoleSystem.self)
    var electricCoilSystem = GKComponentSystem(componentClass: ElectricCoilSystem.self)
    var purpleSlimeSystem = GKComponentSystem(componentClass: PurpleSlimeSystem.self)
    var forceFieldSystem = GKComponentSystem(componentClass: ForceFieldSystem.self)
    
    var playerInput: InputComponent? {
        return player?.component(ofType: InputComponent.self)
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
        
        let overlay = SKSpriteNode(imageNamed: "Overlay")
        overlay.name = "DustOverlay"
        overlay.alpha = 0
        overlay.zPosition = 3
        overlay.setScale(8.5)
        overlay.texture?.filteringMode = .nearest
        mainCamera.addChild(overlay)
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "MapEarth")
        background.position = CGPoint(
            x: levelConfig.mapWidth / 2,
            y: levelConfig.finishLineY / 2 - 170
        )
        background.size = CGSize(
            width: levelConfig.mapWidth,
            height: levelConfig.finishLineY + 320
        )
        background.zPosition = -10
        background.texture?.filteringMode = .nearest
        addChild(background)
    }
    
    private func setupFloor() {
        let node = SKSpriteNode(color: .clear, size: levelConfig.floorSize)
        node.position = CGPoint(
            x: levelConfig.mapWidth / 2,
            y: levelConfig.startY
        )
        node.name = "Floor"
        node.zPosition = 0
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.floor
        node.physicsBody?.contactTestBitMask = PhysicsCategory.none
        node.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        addChild(node)
    }
    
    private func setupWalls() {
        let wallHeight = levelConfig.finishLineY + 500
        let playerHalfWidth: CGFloat = 32
        
        // Left wall
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: playerHalfWidth - wallThickness / 2, y: wallHeight / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: wallHeight))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.friction = 0
        leftWall.physicsBody?.restitution = 0
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.floor
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(leftWall)
        
        // Right wall
        let rightWall = SKNode()
        rightWall.position = CGPoint(x: levelConfig.mapWidth - playerHalfWidth + wallThickness / 2, y: wallHeight / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: wallHeight))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.friction = 0
        rightWall.physicsBody?.restitution = 0
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.floor
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(rightWall)
    }
    
    private func setupUI() {
        let marginX = frame.width / 2 - 200
        let marginY = frame.height / 2 - 200
        
        let joystick = JoystickNode()
        let jumpButton = JumpNode(iconName: "chevron.up.2")
        
        joystick.position = CGPoint(x: -marginX, y: -marginY)
        joystick.zPosition = 4
        
        jumpButton.position = CGPoint(x: marginX, y: -marginY)
        jumpButton.zPosition = 4
        
        joystick.onDirectionChange = { [weak self] direction in
            self?.playerInput?.joystickDirection = direction
        }
        
        jumpButton.onTap = { [weak self] in
            self?.playerInput?.wantsToJump = true
        }
        
        mainCamera.addChild(joystick)
        mainCamera.addChild(jumpButton)
    }
    
    private func setupTraps() {
        enumerateChildNodes(withName: "//BlackHole") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .blackHole)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "BlackHole",
                                   prefix: "BH",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
                
                self.blackHoleSystem.addComponent(foundIn: trapEntity)
            }
        }
        enumerateChildNodes(withName: "//ElectricCoil") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .electricCoil)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "ElectricCoil",
                                   prefix: "EC",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//PurpleSlime") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .purpleSlime)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "PurpleSlime",
                                   prefix: "PS",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//ForceField") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .forceField)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "ForceField",
                                   prefix: "FF",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
        enumerateChildNodes(withName: "//CometDust") { node, _ in
            if let sprite = node as? SKSpriteNode {
                let trapEntity = TrapEntity(node: sprite, type: .cometDust)
                
                self.animateSprite(sprite: sprite,
                                   atlasName: "CometDust",
                                   prefix: "CD",
                                   duration: 0.1)
                
                self.entities.append(trapEntity)
            }
        }
    }
    
    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            if let startPosition = generatedLevel?.startPositions.first {
                node.position = startPosition
            }
            
            mainCamera.position = CGPoint(
                x: node.position.x,
                y: node.position.y + cameraOffsetY
            )
            
            let cameraBounds = CGRect(
                x: -wallThickness,
                y: 0,
                width: levelConfig.mapWidth + wallThickness * 2,
                height: levelConfig.finishLineY
            )
            let playerEntity = PlayerEntity(
                node: node,
                camera: mainCamera,
                cameraBounds: cameraBounds
            )
            self.player = playerEntity
            self.entities.append(playerEntity)
            
            movementSystem.addComponent(foundIn: playerEntity)
            cameraSystem.addComponent(foundIn: playerEntity)
            stateSystem.addComponent(foundIn: playerEntity)
        }
    }
    
    private func setupLevel() {
        let seed = levelSeed ?? UInt64(Date().timeIntervalSince1970)

        let generator = LevelGenerator(
            config: levelConfig,
            seed: seed
        )
        
        let level = generator.generate()
        generatedLevel = level
        
        for platform in level.platforms {
            spawnPlatformEntity(platform)
        }
    }
    
    private func spawnPlatformEntity(_ data: GeneratedPlatform) {
        let node = SKSpriteNode(imageNamed: data.textureName)
        node.position = data.position
        node.size = levelConfig.platformSize
        node.name = "Platform"
        node.zPosition = 1
        node.texture?.filteringMode = .nearest
        
        // Debug coloring
//        switch data.type {
//        case .backbone:   node.color = .blue;      node.colorBlendFactor = 1
//        case .bridge:     node.color = .magenta;   node.colorBlendFactor = 1
//        case .start:      node.color = .orange;    node.colorBlendFactor = 1
//        case .decoration: node.color = .red;       node.colorBlendFactor = 1
//        }
        
        addChild(node)
        
        let platformEntity = PlatformEntity(node: node)
        entities.append(platformEntity)
    }
    
    private func setupDebugGrid() {
        guard showDebugGrid else { return }

        let gridNode = SKNode()
        gridNode.name = "DebugGrid"
        gridNode.zPosition = -5

        let cellWidth = levelConfig.mapWidth / CGFloat(levelConfig.gridColumns)
        let rowHeight = levelConfig.finishLineY / CGFloat(levelConfig.gridRows + 2)

        // Vertical column lines
        for column in 0...levelConfig.gridColumns {
            let x = CGFloat(column) * cellWidth

            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: levelConfig.startY))
            path.addLine(to: CGPoint(x: x, y: levelConfig.finishLineY))

            let line = SKShapeNode(path: path)
            line.strokeColor = .cyan.withAlphaComponent(0.35)
            line.lineWidth = 1
            gridNode.addChild(line)
        }

        // Horizontal row lines
        for row in 0...levelConfig.gridRows {
            let y = levelConfig.startY + CGFloat(row) * rowHeight

            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: levelConfig.mapWidth, y: y))

            let line = SKShapeNode(path: path)
            line.strokeColor = .yellow.withAlphaComponent(0.25)
            line.lineWidth = 1
            gridNode.addChild(line)
        }

        // Mark column centers
        for column in 0..<levelConfig.gridColumns {
            let x = CGFloat(column) * cellWidth + cellWidth / 2

            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: levelConfig.startY))
            path.addLine(to: CGPoint(x: x, y: levelConfig.finishLineY))

            let line = SKShapeNode(path: path)
            line.strokeColor = .white.withAlphaComponent(0.15)
            line.lineWidth = 1
            gridNode.addChild(line)
        }

        addChild(gridNode)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        setupCamera()
        setupBackground()
        setupFloor()
        setupWalls()
        setupDebugGrid()
        setupLevel()
        setupTraps()
        setupPlayer()
        setupUI()
    }
    
    // MARK: - Update
    
    private func updateOneWayPlatformCollision() {
        guard let playerNode = player?.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode,
              let body = playerNode.physicsBody
        else { return }

        var collisionMask: UInt32 = PhysicsCategory.trap | PhysicsCategory.floor

        let playerBottomY = playerNode.position.y - playerNode.size.height / 2
        let lastBottomY = previousPlayerBottomY ?? playerBottomY
        previousPlayerBottomY = playerBottomY

        // Moving upward: allow pass through platforms from below
        if body.velocity.dy > 0 {
            body.collisionBitMask = collisionMask
            return
        }

        let playerHalfWidth = playerNode.size.width / 2
        let tolerance: CGFloat = 8

        var shouldCollideWithPlatform = false

        enumerateChildNodes(withName: "//Platform") { node, stop in
            guard let platform = node as? SKSpriteNode else { return }

            let platformTopY = platform.position.y + platform.size.height / 2 - 4

            let platformColliderWidth = platform.size.width * 0.75
            let platformLeft = platform.position.x - platformColliderWidth / 2
            let platformRight = platform.position.x + platformColliderWidth / 2

            let playerLeft = playerNode.position.x - playerHalfWidth
            let playerRight = playerNode.position.x + playerHalfWidth

            let isHorizontallyOverPlatform =
                playerRight > platformLeft &&
                playerLeft < platformRight

            // Turn collision on if the player was above the platform last frame and is now falling toward/past the platform top.
            let crossedPlatformFromAbove =
                lastBottomY >= platformTopY - tolerance &&
                playerBottomY <= platformTopY + tolerance

            let isCurrentlyAbovePlatform =
                playerBottomY >= platformTopY - tolerance

            if isHorizontallyOverPlatform &&
                (crossedPlatformFromAbove || isCurrentlyAbovePlatform) {
                shouldCollideWithPlatform = true
                stop.pointee = true
            }
        }

        if shouldCollideWithPlatform {
            collisionMask |= PhysicsCategory.platform
        }

        body.collisionBitMask = collisionMask
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        
        updateOneWayPlatformCollision()

        blackHoleSystem.update(deltaTime: dt)
        movementSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)
        stateSystem.update(deltaTime: dt)
        
        lastUpdateTime = currentTime
    }
}

extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (PhysicsCategory.player | PhysicsCategory.trap) {
            let playerNode = (contact.bodyA.categoryBitMask == PhysicsCategory.player) ? contact.bodyA.node : contact.bodyB.node
            let trapNode = (contact.bodyA.categoryBitMask == PhysicsCategory.trap) ? contact.bodyA.node : contact.bodyB.node
            
            handleContact(playerNode: playerNode, trapNode: trapNode)
        }
    }
    
    private func handleContact(playerNode: SKNode?, trapNode: SKNode?) {
        guard let playerEntity = playerNode?.entity as? PlayerEntity,
              let trapEntity = trapNode?.entity as? TrapEntity else
        { return }
        
        for component in trapEntity.components {
            if let interactionHandler = component as? TrapProtocol {
                interactionHandler.didContact(player: playerEntity)
            }
        }
    }
    
    private func animateSprite(sprite: SKSpriteNode, atlasName: String, prefix: String, duration: TimeInterval = 0.1) {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames: [SKTexture] = []
        
        let textureNames = atlas.textureNames.sorted()
        
        for i in 1...textureNames.count {
            let textureName = "\(prefix)-Frame-\(i)"
            frames.append(atlas.textureNamed(textureName))
        }
        
        let animation = SKAction.animate(with: frames, timePerFrame: duration)
        sprite.run(SKAction.repeatForever(animation))
    }
}
