//
//  ElectricCoilSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class ElectricCoilSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .electricCoil,
              !trapData.isOnCooldown
        else { return }
        
        trapData.isOnCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + trapData.cooldown) {
            trapData.isOnCooldown = false
        }
        
        if let stateComp = player.component(ofType: StatusComponent.self) {
            if let stunned = stateComp.stateMachine.state(forClass: StunnedState.self) {
                stunned.duration = trapData.effectDuration
            }
            
            stateComp.stateMachine.enter(StunnedState.self)
        }
    }
}
