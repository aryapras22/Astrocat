//
//  GameScene.swift
//  Wildsnare
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
    
    var playerInput: InputComponent? {
        return player?.component(ofType: InputComponent.self)
    }
    
    // MARK: - Setup
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
        setupPlayer()
        setupUI()
    }
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
    }
    
    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            let playerEntity = PlayerEntity(node: node, camera: mainCamera)
            self.player = playerEntity
            
            moveSystem.addComponent(foundIn: playerEntity)
            cameraSystem.addComponent(foundIn: playerEntity)
        }
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
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        
        moveSystem.update(deltaTime: dt)
        cameraSystem.update(deltaTime: dt)
        
        lastUpdateTime = currentTime
    }
}
