//
//  MovementSystem.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

import GameplayKit

class MovementSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        // Get Component Data
        guard let node = entity?.component(ofType: GKSKNodeComponent.self)?.node,
              let input = entity?.component(ofType: InputComponent.self),
              let moveData = entity?.component(ofType: MovementComponent.self),
              let stateComp = entity?.component(ofType: StateComponent.self)
        else { return }
        
        // Handle Stunned State
        if stateComp.stateMachine.currentState is StunnedState {
            node.physicsBody?.velocity.dx = 0
            return
        }
        
        // Handle Movement Input
        let direction = input.joystickDirection
        node.physicsBody?.velocity.dx = direction * moveData.speed
        
        // Handle Facing Direction
        if direction != 0 {
            node.xScale = direction > 0 ? abs(node.xScale) : -abs(node.xScale)
        }
        
        // Handle Jump
        if input.wantsToJump && !(stateComp.stateMachine.currentState is JumpingState) {
            stateComp.stateMachine.enter(JumpingState.self)
            
            node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: moveData.impulse))
            
            input.wantsToJump = false
        }
    }
}
