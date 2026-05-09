//
//  JumpingState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit

class JumpingState: GKState {
    weak var entity: GKEntity?
    
    init(entity: GKEntity) {
        self.entity = entity
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Start Jump Animation")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node else { return }
        
        if abs(node.physicsBody?.velocity.dy ?? 0) < 0.1 {
            stateMachine?.enter(IdleState.self)
        }
    }
}
