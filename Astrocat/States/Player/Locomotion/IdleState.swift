//
//  IdleState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class IdleState: GKState {
    unowned let locomotionComponent: LocomotionComponent
    
    lazy var idleAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Idle", prefix: "NI")
    }()
    
    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self || stateClass == RunningState.self
    }
    
    override func didEnter(from previousState: GKState?) {        
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(idleAnimation, withKey: "playerAnimation")
    }
}
