//
//  CameraComponent.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 01/05/26.
//

import GameplayKit
import SpriteKit

class CameraComponent: GKComponent {
    let cameraNode: SKCameraNode
    var target: SKNode?
    
    init(camera: SKCameraNode) {
        self.cameraNode = camera
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.cameraNode = SKCameraNode()
        super.init()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let target = target else { return }
        
        cameraNode.position.x += (target.position.x - cameraNode.position.x) * 0.1
        cameraNode.position.y += (target.position.y - cameraNode.position.y) * 0.1
    }
}
