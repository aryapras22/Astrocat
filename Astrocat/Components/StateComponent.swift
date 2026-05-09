//
//  StateComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class StateComponent: GKComponent {
    let stateMachine: GKStateMachine
    
    init(states: [GKState]) {
        self.stateMachine = GKStateMachine(states: states)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        stateMachine.update(deltaTime: seconds)
    }
}
