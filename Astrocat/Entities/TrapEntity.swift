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
        addComponent(GKSKNodeComponent(node: node))
        
        // Trap Management
        addComponent(TrapComponent(type: type))
        
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
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
