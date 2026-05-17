//
//  CameraSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit
import SpriteKit

class CameraSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let data = entity?.component(ofType: CameraComponent.self),
              let target = data.target
        else { return }
        
        let targetPosition = CGPoint(
            x: target.position.x + data.offset.x,
            y: target.position.y + data.offset.y
        )
        
        let dx = targetPosition.x - data.cameraNode.position.x
        let dy = targetPosition.y - data.cameraNode.position.y
        
        data.cameraNode.position.x += dx * data.lerpFactor
        data.cameraNode.position.y += dy * data.lerpFactor
    }
}
