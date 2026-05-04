//
//  MoveComponent.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import GameplayKit
import SpriteKit

class MoveComponent: GKComponent {
    let speed: CGFloat = 200
    
    var stateMachine: GKStateMachine?
    
    override func didAddToEntity() {
        guard let entity = entity else { return }
        
        stateMachine = GKStateMachine(states: [
            IdleState(entity: entity),
            JumpingState(entity: entity)
        ])
        
        stateMachine?.enter(IdleState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let input = entity?.component(ofType: InputComponent.self) else {
            return
        }
        
        // Handle Horizontal Movement
        let direction = input.joystickDirection
        node.physicsBody?.velocity.dx = direction * speed
        
        // Handle Facing Direction
        if direction > 0 {
            node.xScale = abs(node.xScale)
        } else if direction < 0 {
            node.xScale = -abs(node.xScale)
        }
        
        // Handle State Logic
        stateMachine?.update(deltaTime: seconds)
    }
}
