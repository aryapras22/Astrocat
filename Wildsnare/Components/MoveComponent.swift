//
//  MoveComponent.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameplayKit

class MoveComponent: GKComponent {
    let speed: CGFloat = 100
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let nodeComponent = entity?.component(ofType: GKSKNodeComponent.self) else { return }
        let node = nodeComponent.node
        
        node.position.x += speed * CGFloat(seconds)
    }
}
