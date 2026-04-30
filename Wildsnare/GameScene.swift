//
//  GameScene.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameKit
import GameplayKit

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    private var joystick: SKShapeNode?
    private var jumpButton: SKShapeNode?
    
    var playerMoveComponent: MoveComponent? {
        return entities.first?.component(ofType: MoveComponent.self)
    }
    
    func setupUI() {
        let cornerMargin: CGFloat = 150
        let buttonSize: CGFloat = 60
        
        joystick = SKShapeNode(circleOfRadius: buttonSize)
        if let joy = joystick {
            joy.position = CGPoint(x: frame.minX + cornerMargin, y: frame.minY + cornerMargin)
            joy.strokeColor = .white
            joy.fillColor = .white.withAlphaComponent(0.3)
            joy.zPosition = 100
            addChild(joy)
        }
        
        jumpButton = SKShapeNode(circleOfRadius: buttonSize)
        if let btn = jumpButton {
            btn.position = CGPoint(x: frame.maxX - cornerMargin, y: frame.minY + cornerMargin)
            btn.strokeColor = .white
            btn.fillColor = .cyan.withAlphaComponent(0.5)
            btn.zPosition = 100
            addChild(btn)
        }
    }
    
    func setupPlayer() {
        if let existingNode = self.childNode(withName: "//Player") as? SKSpriteNode {
            existingNode.texture?.filteringMode = .nearest
            
            let playerEntity = GKEntity()
            
            let nodeComponent = GKSKNodeComponent(node: existingNode)
            playerEntity.addComponent(nodeComponent)
            
            let moveComponent = MoveComponent()
            playerEntity.addComponent(moveComponent)
            
            self.entities.append(playerEntity)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupUI()
        setupPlayer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if jumpButton?.contains(location) == true {
                playerMoveComponent?.jump()
            }
            
            if joystick?.contains(location) == true {
                let joystickCenter = joystick?.position.x ?? 0
                playerMoveComponent?.direction = (location.x < joystickCenter) ? -1 : 1
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if joystick?.contains(location) == true {
                let joystickCenter = joystick?.position.x ?? 0
                playerMoveComponent?.direction = (location.x < joystickCenter) ? -1 : 1
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerMoveComponent?.direction = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
