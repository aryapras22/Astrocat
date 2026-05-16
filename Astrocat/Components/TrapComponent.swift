//
//  TrapComponent.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit

class TrapComponent: GKComponent {
    let type: TrapType
    
    // All Traps
    var duration: TimeInterval = 5.0
    var cooldown: TimeInterval = 3.0
    var isOnCooldown: Bool = false
    var lastActivationTime: TimeInterval = 0.0
    
    // Black Hole & Force Field
    var radius: CGFloat = 150.0
    var pullForce: CGFloat = 1000.0
    var impulseForce: CGFloat = 100.0
    var repelDuration: TimeInterval = 1.0
    
    // Purple Slime, Electric Coil & Comet Dust
    var speedMofidier: CGFloat = 0.5
    var effectDuration: TimeInterval = 2.0
    
    init(type: TrapType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
