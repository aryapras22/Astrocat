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
    private let mainCamera = SKCameraNode()
    
    var playerMoveComponent: MoveComponent? {
        return entities.first?.component(ofType: MoveComponent.self)
    }
    
    // MARK: - Setup
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
        setupUI()
        setupPlayer()
    }
    
    private func setupCamera() {
        addChild(mainCamera)
        self.camera = mainCamera
    }
    
    private func setupUI() {
        let marginX = frame.width / 2 - 200
        let marginY = frame.height / 2 - 200
        
        joystickHome = CGPoint(x: -marginX, y: -marginY)
        
        // Joystick Setup
        let base = SKShapeNode(circleOfRadius: 60)
        base.position = joystickHome
        base.strokeColor = .white
        base.fillColor = .white.withAlphaComponent(0.1)
        base.zPosition = 1000
        
        // Joystick Knob
        let knob = SKShapeNode(circleOfRadius: 30)
        knob.fillColor = .white.withAlphaComponent(0.8)
        knob.zPosition = 1
        base.addChild(knob)
        joystickKnob = knob
        
        // Add Joystick to Camera
        mainCamera.addChild(base)
        joystickBase = base
        
        // Jump Button Setup
        let jBtn = SKShapeNode(circleOfRadius: 60)
        jBtn.position = CGPoint(x: marginX, y: -marginY)
        jBtn.strokeColor = .white
        jBtn.fillColor = .white.withAlphaComponent(0.1)
        jBtn.zPosition = 1000
        
        // Add Jump Button to Camera
        mainCamera.addChild(jBtn)
        jumpButton = jBtn
        
        // Render Jump Icon
        if let iconTex = textureFromSymbol(name: "chevron.up.2", color: .white) {
            let icon = SKSpriteNode(texture: iconTex)
            icon.zPosition = 1
            jBtn.addChild(icon)
        }
    }
    
    private func setupPlayer() {
        if let node = childNode(withName: "//Player") as? SKSpriteNode {
            node.texture?.filteringMode = .nearest
            
            // Setup Player Entity & Movement
            let entity = GKEntity()
            entity.addComponent(GKSKNodeComponent(node: node))
            entity.addComponent(MoveComponent())
            
            // Setup Player Camera
            let camComponent = CameraComponent(camera: mainCamera)
            camComponent.target = node
            entity.addComponent(camComponent)
            
            entities.append(entity)
        }
    }
    
    // MARK: - Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locInCamera = touch.location(in: mainCamera)
            let locInScene = touch.location(in: self)
            
            
            if locInScene.x < 0 && activeJoystickTouch == nil {
                activeJoystickTouch = touch
                updateJoystick(touch: touch)
            }
            
            else if jumpButton?.contains(locInCamera) == true {
                jumpButton?.run(SKAction.sequence([
                    SKAction.scale(to: 0.9, duration: 0.1),
                    SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
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
        
        let touchLoc = touch.location(in: mainCamera)
        
        let dx = touchLoc.x - joystickHome.x
        let dy = touchLoc.y - joystickHome.y
        let dist = sqrt(dx*dx + dy*dy)
        let angle = atan2(dy, dx)
        
        let knobDist = min(dist, 60)
        knob.position = CGPoint(x: cos(angle) * knobDist, y: sin(angle) * knobDist)
        
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
