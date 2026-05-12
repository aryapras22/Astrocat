//
//  PlatformEntity.swift
//  Astrocat
//
//  Created by Andrew Wallace on 11/05/26.
//

import GameplayKit
import SpriteKit

class PlatformEntity: GKEntity {
    init(node: SKSpriteNode) {
        super.init()
        
        // Visuals
        node.texture?.filteringMode = .nearest
        addComponent(GKSKNodeComponent(node: node))
        
        // Make platform collider thinner so the player doesn't float
        let colliderHeight: CGFloat = 8
        let colliderCenterY: CGFloat = node.size.height / 2 - colliderHeight / 2 - 4
        let colliderWidth: CGFloat = node.size.width * 0.75
        
        node.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: colliderWidth, height: colliderHeight),
            center: CGPoint(x: 0, y: colliderCenterY)
        )
        
        // Collision
        addComponent(
            CollisionComponent(
                categoryBitMask: PhysicsCategory.platform,
                contactTestBitMask: PhysicsCategory.none,
                collisionBitMask: PhysicsCategory.player,
                isDynamic: false,
                friction:
                    0.0
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
