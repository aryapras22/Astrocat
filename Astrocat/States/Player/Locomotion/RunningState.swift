//
//  RunningState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 18/05/26.
//

import GameplayKit
import SpriteKit

class RunningState: GKState {
    unowned let locomotionComponent: LocomotionComponent
    
    lazy var runAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Run", prefix: "NR")
    }()
    
    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self || stateClass == IdleState.self
    }
    
    override func didEnter(from previousState: GKState?) {        
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(runAnimation, withKey: "playerAnimation")
    }
}
