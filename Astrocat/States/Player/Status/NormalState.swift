//
//  NormalState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit

class NormalState: GKState {
    unowned let statusComp: StatusComponent
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == SlowedDownState.self || stateClass == StunnedState.self || stateClass == ObscuredState.self || stateClass == RepelledState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("No Status Is Applied")
    }
    
    override func update(deltaTime seconds: TimeInterval) {

    }
}
