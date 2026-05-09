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
            print("Force Field System is not yet implemented")
            //            addComponent(ForceFieldSystem())
        case .purpleSlime:
            print("Purple Slime System is not yet implemented")
            //            addComponent(PurpleSlimeSystem())
        case .electricCoil:
            print("Electric Coil System is not yet implemented")
            //            addComponent(ElectricCoilSystem())
        case .cometDust:
            print("Comet Dust System is not yet implemented")
            //            addComponent(CometDustSystem())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
