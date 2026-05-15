//
//  RepelledState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 15/05/26.
//

import GameplayKit

class RepelledState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        print("Start Repelled Animation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(NormalState.self)
        }
    }
}
