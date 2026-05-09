//
//  BlackHoleSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class BlackHoleSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let trapData = entity?.component(ofType: TrapComponent.self),
              trapData.type == .blackHole
        else { return }
        
        guard let trapNode = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let scene = trapNode.scene as? GameScene,
              let playerNode = scene.player?.component(ofType: GKSKNodeComponent.self)?.node
        else { return }
        
        let dx = trapNode.position.x - playerNode.position.x
        let dy = trapNode.position.y - playerNode.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < trapData.radius {
            let forceVector = CGVector(dx: (dx / distance) * trapData.pullForce,
                                       dy: (dy / distance) * trapData.pullForce)
            playerNode.physicsBody?.applyForce(forceVector)
        }
    }
}
