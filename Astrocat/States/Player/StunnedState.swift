//
//  StunnedState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

class StunnedState: GKState {
    weak var entity: GKEntity?
    var duration: TimeInterval = 0.0
    var elapsed: TimeInterval = 0.0
    
    init(entity: GKEntity) {
        self.entity = entity
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        print("Stunned Animation Started")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(IdleState.self)
        }
    }
}
