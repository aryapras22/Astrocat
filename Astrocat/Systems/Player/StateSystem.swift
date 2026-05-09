//
//  StateSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 10/05/26.
//

import GameplayKit

class StateSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let stateData = entity?.component(ofType: StateComponent.self) else { return }
        
        stateData.stateMachine.update(deltaTime: seconds)
    }
}
