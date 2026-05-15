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
              let locomotion = entity?.component(ofType: LocomotionComponent.self),
              let status = entity?.component(ofType: StatusComponent.self)
        else { return }
        
        // Local Variable for Dynamic Speed Manipulation
        var currentSpeed = moveData.speed
        var currentImpulse = moveData.impulse
        
        // Handle Slowed Down Status
        if let slowedState = status.stateMachine.currentState as? SlowedDownState {
            currentSpeed *= slowedState.modifier
            currentImpulse *= slowedState.modifier
        }
        
        // Handle Stunned State
        if status.stateMachine.currentState is StunnedState {
            node.physicsBody?.velocity.dx = 0
            return
        }
        
        // Handle Repelled Status
        if status.stateMachine.currentState is RepelledState {
            return
        }

        // Handle Movement Input
        let direction = input.joystickDirection
        node.physicsBody?.velocity.dx = direction * currentSpeed
        
        // Handle Facing Direction
        if direction != 0 {
            node.xScale = direction > 0 ? abs(node.xScale) : -abs(node.xScale)
        }
        
        // Handle Jump
        if input.wantsToJump {
            if !(locomotion.stateMachine.currentState is JumpingState) {
                locomotion.stateMachine.enter(JumpingState.self)
                
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: currentImpulse))
            }
            
            input.wantsToJump = false
        }
    }
}
