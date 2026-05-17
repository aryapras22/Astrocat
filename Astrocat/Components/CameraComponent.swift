//
//  CameraComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 01/05/26.
//

import GameplayKit
import SpriteKit

class CameraComponent: GKComponent {
    let cameraNode: SKCameraNode
    var target: SKNode?
    var lerpFactor: CGFloat = 0.1
    var offset = CGPoint(x: 0, y: 260)
    var bounds: CGRect?

    init(camera: SKCameraNode) {
        self.cameraNode = camera
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.cameraNode = SKCameraNode()
        super.init()
    }
}
