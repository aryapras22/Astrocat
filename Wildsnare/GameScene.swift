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
    private var jumpButton: SKShapeNode?
    private var joystickBase: SKShapeNode?
    private var joystickKnob: SKShapeNode?
    private let buttonRadius: CGFloat = 60
    
    var playerMoveComponent: MoveComponent? {
        return entities.first?.component(ofType: MoveComponent.self)
    }
    
    func textureFromSymbol(name: String, color: UIColor) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        guard let symbol = UIImage(systemName: name, withConfiguration: config) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: symbol.size)
        let renderedImage = renderer.image { context in
            color.set()
            symbol.withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
        
        return SKTexture(image: renderedImage)
    }
    
    func setupUI() {
        let cornerMargin: CGFloat = 150
        
        joystickBase = SKShapeNode(circleOfRadius: buttonRadius)
        if let base = joystickBase {
            base.position = CGPoint(x: frame.minX + cornerMargin, y: frame.minY + cornerMargin)
            base.strokeColor = .white
            base.fillColor = .white.withAlphaComponent(0.1)
            base.zPosition = 100
            addChild(base)
            
            joystickKnob = SKShapeNode(circleOfRadius: 30)
            if let knob = joystickKnob {
                knob.fillColor = .white.withAlphaComponent(0.8)
                knob.zPosition = 1
                base.addChild(knob)
            }
        }
        
        let jumpBase = SKShapeNode(circleOfRadius: buttonRadius)
        jumpBase.position = CGPoint(x: frame.maxX - cornerMargin, y: frame.minY + cornerMargin)
        jumpBase.strokeColor = .white
        jumpBase.fillColor = .white.withAlphaComponent(0.1)
        jumpBase.zPosition = 100
        self.jumpButton = jumpBase
        addChild(jumpBase)
        
        if let whiteTexture = textureFromSymbol(name: "chevron.up.2", color: .white) {
            let icon = SKSpriteNode(texture: whiteTexture)
            icon.zPosition = 1
            
            jumpBase.addChild(icon)
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
    
    func updateJoystick(touch: UITouch) {
        guard let base = joystickBase, let knob = joystickKnob else { return }
        
        let location = touch.location(in: base)
        let distance = sqrt(pow(location.x, 2) + pow(location.y, 2))
        
        if distance < buttonRadius {
            knob.position = location
        } else {
            let angle = atan2(location.y, location.x)
            knob.position = CGPoint(x: cos(angle) * buttonRadius, y: sin(angle) * buttonRadius)
        }
        
        playerMoveComponent?.direction = knob.position.x / buttonRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if jumpButton?.contains(location) == true {
                jumpButton?.run(SKAction.group([
                    SKAction.scale(to: 0.9, duration: 0.1),
                    SKAction.colorize(with: .white, colorBlendFactor: 0.2, duration: 0.1)
                ]))
                
                playerMoveComponent?.jump()
            }
            
            if joystickBase?.contains(location) == true {
                updateJoystick(touch: touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if joystickBase?.contains(location) == true {
                updateJoystick(touch: touch)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.x > 0 {
                jumpButton?.run(SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.1),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                ]))
            }
            
            if location.x < 0 {
                joystickKnob?.run(SKAction.move(to: .zero, duration: 0.1))
                playerMoveComponent?.direction = 0
            }
        }
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
