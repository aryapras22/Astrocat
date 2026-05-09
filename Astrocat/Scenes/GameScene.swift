//
//  GameScene.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime: TimeInterval = 0
    private let mainCamera = SKCameraNode()
    
    var player: PlayerEntity?
    var moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
    var cameraSystem = GKComponentSystem(componentClass: CameraComponent.self)
    var blackHoleSystem = GKComponentSystem(componentClass: BlackHoleSystem.self)
    
    var playerInput: InputComponent? {
        return player?.component(ofType: InputComponent.self)
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
    }
    
    private func setupUI() {
        let marginX = frame.width / 2 - 200
        let marginY = frame.height / 2 - 200
        
        let joystick = JoystickNode()
        let jumpButton = JumpNode(iconName: "chevron.up.2")
        
        joystick.position = CGPoint(x: -marginX, y: -marginY)
        joystick.zPosition = 10
        
        jumpButton.position = CGPoint(x: marginX, y: -marginY)
        jumpButton.zPosition = 10
        
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
                
                self.entities.append(trapEntity)
                
                self.blackHoleSystem.addComponent(foundIn: trapEntity)
            }
        }
    }
    
    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            let playerEntity = PlayerEntity(node: node, camera: mainCamera)
            self.player = playerEntity
            
            moveSystem.addComponent(foundIn: playerEntity)
            cameraSystem.addComponent(foundIn: playerEntity)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
        setupUI()
        setupTraps()
        setupPlayer()
    }
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        
        cameraSystem.update(deltaTime: dt)
        blackHoleSystem.update(deltaTime: dt)
        moveSystem.update(deltaTime: dt)
        
        lastUpdateTime = currentTime
    }
}
