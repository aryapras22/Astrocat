//
//  PlayerEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity {
    init(node: SKSpriteNode, camera: SKCameraNode) {
        super.init()
        
        // Visuals
        node.texture?.filteringMode = .nearest
        node.zPosition = 1
        addComponent(GKSKNodeComponent(node: node))
        
        // Movement
        addComponent(InputComponent())
        addComponent(MovementComponent())
        addComponent(MovementSystem())
        
        // Camera
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        addComponent(cameraComponent)
        addComponent(CameraSystem())
        
        // States
        addComponent(LocomotionComponent())
        addComponent(StatusComponent())
        addComponent(StateSystem())
        
        // Physics
        if let body = node.physicsBody {
            body.categoryBitMask = PhysicsCategory.player
            body.contactTestBitMask = PhysicsCategory.trap
            body.collisionBitMask &= ~PhysicsCategory.trap
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
