//
//  PlayerEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity {
    init(node: SKSpriteNode, camera: SKCameraNode, cameraBounds: CGRect) {
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
        cameraComponent.bounds = cameraBounds
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
            body.contactTestBitMask = PhysicsCategory.trap | PhysicsCategory.finish
            body.collisionBitMask = PhysicsCategory.floor
            body.allowsRotation = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
