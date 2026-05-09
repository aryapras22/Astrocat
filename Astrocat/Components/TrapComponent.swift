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
    var effectDuration: TimeInterval = 2.0
    
    // Black Hole & Force Field
    var pullForce: CGFloat = 1000.0
    var radius: CGFloat = 150.0
    
    // Purple Slime
    var speedMofidier: CGFloat = 0.5
    
    init(type: TrapType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
