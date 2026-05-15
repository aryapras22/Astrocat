//
//  ForceFieldSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class ForceFieldSystem: GKComponent, TrapProtocol {
    func didContact(player: PlayerEntity) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .forceField
        else { return }
        
        guard let trapNode = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let scene = trapNode.scene as? GameScene,
              let playerNode = scene.player?.component(ofType: GKSKNodeComponent.self)?.node
        else { return }
        
        let dx = trapNode.position.x - playerNode.position.x
        let dy = trapNode.position.y - playerNode.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if let stateComp = player.component(ofType: StatusComponent.self) {
            if let repelled = stateComp.stateMachine.state(forClass: RepelledState.self) {
                repelled.duration = trapData.repelDuration
                
                let forceVector = CGVector(dx: -(dx / distance) * trapData.impulseForce,
                                           dy: -(dy / distance) * trapData.impulseForce)
                
                playerNode.physicsBody?.applyImpulse(forceVector)
            }
            
            stateComp.stateMachine.enter(RepelledState.self)
        }
    }
}
