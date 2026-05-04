//
//  JoystickNode.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import SpriteKit

class JoystickNode: SKNode {
    private let base: SKShapeNode
    private let knob: SKShapeNode
    private let maxRadius: CGFloat = 60.0
    private var activeTouch: UITouch?
    
    var onDirectionChange: ((CGFloat) -> Void)?
    
    override init() {
        base = SKShapeNode(circleOfRadius: maxRadius)
        base.strokeColor = .white
        base.fillColor = .white.withAlphaComponent(0.1)
        
        knob = SKShapeNode(circleOfRadius: 30)
        knob.fillColor = .white.withAlphaComponent(0.8)
        
        super.init()
        
        addChild(base)
        base.addChild(knob)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Touch Logic
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if activeTouch == nil {
            activeTouch = touches.first
            updateKnob(touch: activeTouch!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = activeTouch, touches.contains(touch) {
            updateKnob(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = activeTouch, touches.contains(touch) {
            activeTouch = nil
            knob.run(SKAction.move(to: .zero, duration: 0.1))
            onDirectionChange?(0.0)
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    private func updateKnob(touch: UITouch) {
        let touchLoc = touch.location(in: self)
        let dist = sqrt(touchLoc.x * touchLoc.x + touchLoc.y * touchLoc.y)
        let angle = atan2(touchLoc.y, touchLoc.x)
        
        let knobDist = min(dist, maxRadius)
        knob.position = CGPoint(x: cos(angle) * knobDist, y: sin(angle) * knobDist)
        
        let rawDir = touchLoc.x / maxRadius
        onDirectionChange?(max(-1.0, min(1.0, rawDir)))
    }
}
