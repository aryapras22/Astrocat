//
//  RepelledState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 15/05/26.
//

import GameplayKit

class RepelledState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    
    lazy var stressAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Stress", prefix: "NS")
    }()
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        
        guard let entity = statusComp.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(stressAnimation, withKey: "playerAnimation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(NormalState.self)
        }
    }
}
