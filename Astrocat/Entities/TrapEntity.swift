//
//  TrapEntity.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 08/05/26.
//

import GameplayKit
import SpriteKit

enum TrapType {
    case blackHole
    case forceField
    case purpleSlime
    case electricCoil
    case cometDust
}

class TrapEntity: GKEntity {
    let trapType: TrapType
    
    init(node: SKSpriteNode, type: TrapType) {
        self.trapType = type
        
        super.init()
        
        // Visuals
        node.texture?.filteringMode = .nearest
        node.zPosition = 2
        addComponent(GKSKNodeComponent(node: node))
        
        // Component
        addComponent(TrapComponent(type: type))
        
        // Systems
        switch type {
        case .blackHole:
            addComponent(BlackHoleSystem())
        case .forceField:
            addComponent(ForceFieldSystem())
        case .purpleSlime:
            addComponent(PurpleSlimeSystem())
        case .electricCoil:
            addComponent(ElectricCoilSystem())
        case .cometDust:
            addComponent(CometDustSystem())
        }
        
        // Physics
        if let body = node.physicsBody {
            body.categoryBitMask = PhysicsCategory.trap
            body.collisionBitMask = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
