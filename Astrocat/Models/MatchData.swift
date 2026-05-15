//
//  MatchData.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import Foundation
import CoreGraphics

enum MatchMode {
    case quickMatch(playerCount: Int)
    case inviteFriend(playerCount: Int)
}

enum MatchManagerState: Equatable, Codable {
    case unauthenticated
    case authenticated
    case inGame
}

enum MessageType: String, Codable {
    case gameStart
    case playerReady
    case roundStart
    case playerUpdate
    case playerFinished
    case finalResults
}

struct RaceResult: Codable {
    var senderID: String
    var playerName: String
    var finishTime: TimeInterval
}

struct GameMessage: Codable {
    var messageType: MessageType
    var randomSeed: UInt64?
    var senderID: String?
    var roundIndex: Int?
    var startTimeEpoch: TimeInterval?
    var playerName: String?
    var playerX: CGFloat?
    var playerY: CGFloat?
    var playerDX: CGFloat?
    var playerDY: CGFloat?
    var finishTime: TimeInterval?
    var finalResults: [RaceResult]?
    
    static func gameStart(randomSeed: UInt64) -> GameMessage {
        GameMessage(messageType: .gameStart, randomSeed: randomSeed)
    }
    static func playerReady(senderID: String) -> GameMessage {
        GameMessage(messageType: .playerReady, senderID: senderID)
    }
    
    static func roundStart(senderID: String, roundIndex: Int, startTimeEpoch: TimeInterval) -> GameMessage {
        GameMessage(messageType: .roundStart, senderID: senderID, roundIndex: roundIndex, startTimeEpoch: startTimeEpoch)
    }
    static func playerUpdate(senderID: String, playerX: CGFloat, playerY: CGFloat, playerDX: CGFloat, playerDY: CGFloat) -> GameMessage {
        GameMessage(messageType: .playerUpdate, senderID: senderID, playerX: playerX, playerY: playerY, playerDX: playerDX, playerDY: playerDY)
    }
    static func playerFinished(senderID: String, finishTime: TimeInterval) -> GameMessage {
        GameMessage(messageType: .playerFinished, senderID: senderID, finishTime: finishTime)
    }
    static func finalResults(finalResults: [RaceResult]) -> GameMessage {
        GameMessage(messageType: .finalResults, finalResults: finalResults)
    }
}
