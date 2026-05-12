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
              trapData.type == .cometDust else { return }
        
        if let status = player.component(ofType: StatusComponent.self) {
            if let obscured = status.stateMachine.state(forClass: ObscuredState.self) {
                obscured.duration = trapData.effectDuration
            }
            status.stateMachine.enter(ObscuredState.self)
        }
    }
}
