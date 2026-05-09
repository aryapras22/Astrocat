//
//  StatusSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class StatusSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let status = entity?.component(ofType: StatusComponent.self) else { return }
        
        if status.slowTimer > 0 {
            status.slowTimer -= seconds
        }
    }
}
