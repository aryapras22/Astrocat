//
//  ObscuredState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit
import SpriteKit

class ObscuredState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0
    var duration: TimeInterval = 0
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        if let camera = statusComp.entity?.component(ofType: CameraComponent.self)?.cameraNode,
           let overlay = camera.childNode(withName: "DustOverlay") {
            overlay.run(SKAction.fadeIn(withDuration: 0.2))
        }
        print("Start Comet Dust Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        if elapsed >= duration {
            stateMachine?.enter(NormalState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let camera = statusComp.entity?.component(ofType: CameraComponent.self)?.cameraNode,
           let overlay = camera.childNode(withName: "DustOverlay") {
            overlay.run(SKAction.fadeOut(withDuration: 0.5))
        }
    }
}
