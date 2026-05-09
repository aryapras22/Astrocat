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
        addComponent(GKSKNodeComponent(node: node))
        
        // Movement
        addComponent(InputComponent())
        addComponent(MovementComponent())
        addComponent(MovementSystem())
        
        // Status
        addComponent(StatusComponent())
        addComponent(StatusSystem())
        
        // Camera
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        addComponent(cameraComponent)
        addComponent(CameraSystem())
        
        // States
        let states = [
            IdleState(entity: self),
            JumpingState(entity: self),
            StunnedState(entity: self),
        ]
        addComponent(StateComponent(states: states))
        
        // Physics
        if let body = node.physicsBody {
            body.categoryBitMask = PhysicsCategory.player
            body.contactTestBitMask = PhysicsCategory.trap
            body.collisionBitMask = PhysicsCategory.trap
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
