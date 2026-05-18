//
//  Animate.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 18/05/26.
//

import SpriteKit

extension SKAction {
    static func buildAnimation(atlasName: String, prefix: String, duration: TimeInterval = 0.1) -> SKAction {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames: [SKTexture] = []
        
        let count = atlas.textureNames.count
        if count > 0 {
            for i in 1...count {
                let textureName = "\(prefix)-Frame-\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
        } else {
            return SKAction.wait(forDuration: duration)
        }
        
        let animation = SKAction.animate(with: frames, timePerFrame: duration)
        return SKAction.repeatForever(animation)
    }
}
