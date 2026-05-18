//
//  NormalState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit

class NormalState: GKState {
    unowned let statusComp: StatusComponent
    
    lazy var runAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Run", prefix: "NR")
    }()
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == SlowedDownState.self || stateClass == StunnedState.self || stateClass == ObscuredState.self || stateClass == RepelledState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let entity = statusComp.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(runAnimation, withKey: "playerAnimation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {

    }
}
