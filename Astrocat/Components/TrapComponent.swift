//
//  TrapComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

class TrapComponent: GKComponent {
    let type: TrapType
    var effectDuration: TimeInterval = 2.0
    var pullForce: CGFloat = 5.0
    var repelForce: CGFloat = 100.0   
    var speedModifier: CGFloat = 0.5
    
    init(type: TrapType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // TODO: Implement Trap Logic
    }
}
