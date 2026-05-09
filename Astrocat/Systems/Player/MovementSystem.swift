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
              let stateComp = entity?.component(ofType: StateComponent.self),
              let status = entity?.component(ofType: StatusComponent.self)
        else { return }
        
        var currentSpeed = moveData.speed
        var currentImpulse = moveData.impulse
        
        // Handle Stunned State
        if stateComp.stateMachine.currentState is StunnedState {
            node.physicsBody?.velocity.dx = 0
            return
        }
        
        // Handle Slowed Down State
        if status.slowTimer > 0 {
            currentSpeed *= status.slowModifier
            currentImpulse *= status.slowModifier
        }
        
        // Handle Movement Input
        let direction = input.joystickDirection
        node.physicsBody?.velocity.dx = direction * currentSpeed
        
        // Handle Facing Direction
        if direction != 0 {
            node.xScale = direction > 0 ? abs(node.xScale) : -abs(node.xScale)
        }
        
        // Handle Jump
        if input.wantsToJump && !(stateComp.stateMachine.currentState is JumpingState) {
            stateComp.stateMachine.enter(JumpingState.self)
            
            node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: currentImpulse))
            
            input.wantsToJump = false
        }
    }
}
