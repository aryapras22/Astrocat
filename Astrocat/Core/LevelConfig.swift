//
//  LevelConfig.swift
//  Astrocat
//
//  Created by Andrew Wallace on 11/05/26.
//

import CoreGraphics

struct LevelConfig {
    let mapWidth: CGFloat
    let finishLineY: CGFloat
    let startY: CGFloat
    let gridColumns: Int
    let gridRows: Int
    let platformSize: CGSize
    let floorSize: CGSize
    
    // Generation tuning
    let decorationProbability: CGFloat
    let chainProbability: CGFloat
    let maxPlatformsPerRow: Int
    
    // Traps
    let blackHoleCount: Int
    let forceFieldCount: Int
    let purpleSlimeCount: Int
    let electricCoilCount: Int
    let cometDustCount: Int
    
    static let defaultConfig = LevelConfig(
        mapWidth: 2500,
        finishLineY: 5000,
        startY: 50,
        gridColumns: 10,
        gridRows: 40,
        platformSize: CGSize(width: 120, height: 40),
        floorSize: CGSize(width: 2500, height: 30),
        decorationProbability: 70,
        chainProbability: 30,
        maxPlatformsPerRow: 3,
        blackHoleCount: 3,
        forceFieldCount: 2,
        purpleSlimeCount: 5,
        electricCoilCount: 4,
        cometDustCount: 4
    )
}
