//
//  PurpleSlimeSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class PurpleSlimeSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .purpleSlime
        else { return }
        
        if let status = player.component(ofType: StatusComponent.self) {
            status.slowTimer = trapData.effectDuration
            status.slowModifier = trapData.speedMofidier
        }
    }
}
