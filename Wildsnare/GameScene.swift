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
    
    // UI Constants & Nodes
    private let joystickRadius: CGFloat = 100
    private var joystickBase: SKShapeNode?
    private var joystickKnob: SKShapeNode?
    private var joystickHome: CGPoint = .zero
    private var jumpButton: SKShapeNode?
    
    private var activeJoystickTouch: UITouch?
    
    var playerMoveComponent: MoveComponent? {
        return entities.first?.component(ofType: MoveComponent.self)
    }

    // MARK: - Setup
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupUI()
        setupPlayer()
    }

    private func setupUI() {
        let margin: CGFloat = 200
        joystickHome = CGPoint(x: frame.minX + margin, y: frame.minY + margin)
        
        // Joystick Setup
        let base = SKShapeNode(circleOfRadius: 60)
        base.position = joystickHome
        base.strokeColor = .white
        base.fillColor = .white.withAlphaComponent(0.1)
        base.zPosition = 1000
        addChild(base)
        joystickBase = base
        
        let knob = SKShapeNode(circleOfRadius: 30)
        knob.fillColor = .white.withAlphaComponent(0.8)
        knob.zPosition = 1
        base.addChild(knob)
        joystickKnob = knob
        
        // Jump Button Setup
        let jBtn = SKShapeNode(circleOfRadius: 60)
        jBtn.position = CGPoint(x: frame.maxX - margin, y: frame.minY + margin)
        jBtn.strokeColor = .white
        jBtn.fillColor = .white.withAlphaComponent(0.1)
        jBtn.zPosition = 1000
        addChild(jBtn)
        jumpButton = jBtn
        
        if let iconTex = textureFromSymbol(name: "chevron.up.2", color: .white) {
            let icon = SKSpriteNode(texture: iconTex)
            icon.zPosition = 1
            jBtn.addChild(icon)
        }
    }

    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            node.texture?.filteringMode = .nearest
            
            let entity = GKEntity()
            entity.addComponent(GKSKNodeComponent(node: node))
            entity.addComponent(MoveComponent())
            
            entities.append(entity) //
        }
    }

    // MARK: - Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            
            if loc.x < 0 && activeJoystickTouch == nil {
                activeJoystickTouch = touch
                updateJoystick(touch: touch)
            } else if jumpButton?.contains(loc) == true {
                jumpButton?.run(SKAction.sequence([
                    SKAction.scale(to: 0.9, duration: 0.1),
                    SKAction.colorize(with: .white, colorBlendFactor: 0.3, duration: 0.1)
                ]))
                playerMoveComponent?.jump()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches where touch == activeJoystickTouch {
            updateJoystick(touch: touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == activeJoystickTouch {
                activeJoystickTouch = nil
                joystickKnob?.run(SKAction.move(to: .zero, duration: 0.1))
                playerMoveComponent?.direction = 0
            } else if touch.location(in: self).x > 0 {
                jumpButton?.run(SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.1),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                ]))
            }
        }
    }

    private func updateJoystick(touch: UITouch) {
        guard let knob = joystickKnob else { return }
        
        let touchLoc = touch.location(in: self)
        let dx = touchLoc.x - joystickHome.x
        let dy = touchLoc.y - joystickHome.y
        let dist = sqrt(dx*dx + dy*dy)
        let angle = atan2(dy, dx)
        
        // Clamp Knob Visually
        let knobDist = min(dist, 60)
        knob.position = CGPoint(x: cos(angle) * knobDist, y: sin(angle) * knobDist)
        
        // Normalize Direction (-1 to 1)
        let rawDir = dx / 60
        playerMoveComponent?.direction = max(-1.0, min(1.0, rawDir))
    }

    // MARK: - Helpers & Loop

    private func textureFromSymbol(name: String, color: UIColor) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold)
        guard let sym = UIImage(systemName: name, withConfiguration: config) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: sym.size)
        let img = renderer.image { _ in
            color.set()
            sym.withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
        return SKTexture(image: img)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        
        for entity in entities {
            entity.update(deltaTime: dt) //
        }
        lastUpdateTime = currentTime
    }
}
