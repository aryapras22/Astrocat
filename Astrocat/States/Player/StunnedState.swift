//
//  StunnedState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

class StunnedState: GKState {
    weak var entity: GKEntity?
    
    init(entity: GKEntity) {
        self.entity = entity
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Stunned Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
