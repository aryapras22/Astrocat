//
//  CometDustSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class CometDustSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .cometDust,
              !trapData.isOnCooldown
        else { return }
        
        trapData.isOnCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + trapData.cooldown) {
            trapData.isOnCooldown = false
        }
        
        if let stateComp = player.component(ofType: StatusComponent.self) {
            if let current = stateComp.stateMachine.currentState as? ObscuredState {
                current.reset()
            } else {
                if let obscured = stateComp.stateMachine.state(forClass: ObscuredState.self) {
                    obscured.duration = trapData.effectDuration
                    stateComp.stateMachine.enter(ObscuredState.self)
                }
            }
        }
    }
}
