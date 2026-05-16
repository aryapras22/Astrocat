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
              trapData.type == .purpleSlime,
              !trapData.isOnCooldown
        else { return }
        
        trapData.isOnCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + trapData.cooldown) {
            trapData.isOnCooldown = false
        }
        
        if let stateComp = player.component(ofType: StatusComponent.self) {
            if let current = stateComp.stateMachine.currentState as? SlowedDownState {
                current.reset()
            } else {
                if let slowedDown = stateComp.stateMachine.state(forClass: SlowedDownState.self) {
                    slowedDown.duration = trapData.effectDuration
                    slowedDown.modifier = trapData.speedMofidier
                    stateComp.stateMachine.enter(SlowedDownState.self)
                }
            }
        }
    }
}
