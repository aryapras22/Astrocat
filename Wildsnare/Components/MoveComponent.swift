//
//  MoveComponent.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameplayKit

class MoveComponent: GKComponent {
    let speed: CGFloat = 200
    let jumpImpulse: CGFloat = 100
    var direction: CGFloat = 0
    
    func jump() {
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node else { return }
        if abs(node.physicsBody?.velocity.dy ?? 0) < 0.1 {
            node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        node.position.x += direction * speed * CGFloat(seconds)
        
        if direction > 0 {
            node.xScale = abs(node.xScale)
        } else if direction < 0 {
            node.xScale = -abs(node.xScale)
        }
    }
}
