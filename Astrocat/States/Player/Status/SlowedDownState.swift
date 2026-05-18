//
//  SlowedDownState.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 12/05/26.
//

import GameplayKit

class SlowedDownState: GKState {
    unowned let statusComp: StatusComponent
    var elapsed: TimeInterval = 0
    var duration: TimeInterval = 0
    var modifier: CGFloat = 0.5
    
    lazy var slimedAnimation: SKAction = {
        return SKAction.buildAnimation(atlasName: "N-Slimed", prefix: "NS")
    }()
    
    init(component: StatusComponent) {
        self.statusComp = component
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        
        guard let entity = statusComp.entity,
              let nodeComponent = entity.component(ofType: GKSKNodeComponent.self),
              let sprite = nodeComponent.node as? SKSpriteNode else {
            return
        }
        
        sprite.run(slimedAnimation, withKey: "playerAnimation")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsed += seconds
        
        if elapsed >= duration {
            self.stateMachine?.enter(NormalState.self)
        }
    }
    
    func reset() {
        self.elapsed = 0
    }
}
