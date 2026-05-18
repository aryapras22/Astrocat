//
//  StateComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class LocomotionComponent: GKComponent {
    var stateMachine: GKStateMachine!
    
    override init() {
        super.init()
        
        let states = [
            IdleState(component: self),
            JumpingState(component: self),
            RunningState(component: self),
        ]
        
        self.stateMachine = GKStateMachine(states: states)
        self.stateMachine.enter(IdleState.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
