//
//  GameScene.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 30/04/26.
//

import SpriteKit
import GameKit
import GameplayKit

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let playerNode = SKSpriteNode(imageNamed: "Dragon")
        playerNode.position = CGPoint(x: 0, y: 0)
        
        let playerEntity = GKEntity()
        
        let nodeComponent = GKSKNodeComponent(node: playerNode)
        playerEntity.addComponent(nodeComponent)
        
        let moveComponent = MoveComponent()
        playerEntity.addComponent(moveComponent)
        
        self.addChild(playerNode)
        
        self.entities.append(playerEntity)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
