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
        
        var targetPosition = CGPoint(
            x: target.position.x + data.offset.x,
            y: target.position.y + data.offset.y
        )
        
//        if let bounds = data.bounds,
//           let scene = data.cameraNode.scene {
//            let halfWidth = scene.size.width / 2
//            let halfHeight = scene.size.height / 2
//            
//            let minX = bounds.minX + halfWidth
//            let maxX = bounds.maxX - halfWidth
//            let maxY = bounds.maxY - halfHeight
//            
//            targetPosition.x = clamp(targetPosition.x, min: minX, max: maxX)
//            targetPosition.y = min(targetPosition.y, maxY)
//        }
        
        let dx = targetPosition.x - data.cameraNode.position.x
        let dy = targetPosition.y - data.cameraNode.position.y
        
        data.cameraNode.position.x += dx * data.lerpFactor
        data.cameraNode.position.y += dy * data.lerpFactor
    }
    
    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
