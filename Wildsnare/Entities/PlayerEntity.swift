//
//  PlayerEntity.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity {
    init(node: SKSpriteNode, camera: SKCameraNode) {
        super.init()
        
        node.texture?.filteringMode = .nearest
        
        let visualComponent = GKSKNodeComponent(node: node)
        addComponent(visualComponent)
        
        let InputComponent = InputComponent()
        addComponent(InputComponent)
        
        let moveComponent = MoveComponent()
        addComponent(moveComponent)
        
        let cameraComponent = CameraComponent(camera: camera)
        cameraComponent.target = node
        addComponent(cameraComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
