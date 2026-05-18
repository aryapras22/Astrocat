//
//  StunnedState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

class StunnedState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    
    lazy var stunnedAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "Electrified", prefix: "PE")
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
        
        sprite.run(stunnedAnimation, withKey: "playerAnimation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(NormalState.self)
        }
    }
}
