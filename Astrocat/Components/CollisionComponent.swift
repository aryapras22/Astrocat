//
//  CollisionComponent.swift
//  Astrocat
//
//  Created by Andrew Wallace on 11/05/26.
//

import GameplayKit
import SpriteKit

class CollisionComponent: GKComponent {
    let categoryBitMask: UInt32
    let contactTestBitMask: UInt32
    let collisionBitMask: UInt32
    let isDynamic: Bool
    let friction: CGFloat
    
    init(
        categoryBitMask: UInt32,
        contactTestBitMask: UInt32 = PhysicsCategory.none,
        collisionBitMask:  UInt32 = PhysicsCategory.none,
        isDynamic: Bool = false,
        friction: CGFloat = 0.2
    ) {
        self.categoryBitMask = categoryBitMask
        self.contactTestBitMask = contactTestBitMask
        self.collisionBitMask = collisionBitMask
        self.isDynamic = isDynamic
        self.friction = friction
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToEntity() {
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode else {
            return
        }
        
        if node.physicsBody == nil {
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        }
        
        node.physicsBody?.isDynamic = isDynamic
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = contactTestBitMask
        node.physicsBody?.collisionBitMask = collisionBitMask
        node.physicsBody?.friction = friction
    }
}
