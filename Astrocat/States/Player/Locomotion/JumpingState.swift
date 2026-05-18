//
//  JumpingState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit
import SpriteKit

class JumpingState: GKState {
    unowned let locomotionComponent: LocomotionComponent

    lazy var jumpAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Jump", prefix: "NJ")
    }()

    init(component: LocomotionComponent) {
        self.locomotionComponent = component
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self || stateClass == RunningState.self
    }

    override func didEnter(from previousState: GKState?) {
        print("Start Jump Animation")
        
        guard let entity = locomotionComponent.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(jumpAnimation, withKey: "playerAnimation")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let entity = locomotionComponent.entity,
              let node = entity.component(ofType: GKSKNodeComponent.self)?.node
        else { return }

        if abs(node.physicsBody?.velocity.dy ?? 0) < 0.1 {
            stateMachine?.enter(IdleState.self)
        }
    }
}
