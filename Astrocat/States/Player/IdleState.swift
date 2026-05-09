//
//  IdleState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import GameplayKit

class IdleState: GKState {
    weak var entity: GKEntity?
    
    init(entity: GKEntity) {
        self.entity = entity
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == JumpingState.self || stateClass == StunnedState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Start Idle Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {

    }
}
