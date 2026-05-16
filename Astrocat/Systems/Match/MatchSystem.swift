//
//  MatchSystem.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import GameKit
import Combine

@MainActor
class MatchSystem: NSObject, ObservableObject, GKMatchDelegate, GKLocalPlayerListener, GKMatchmakerViewControllerDelegate {
    
    // MARK: Properties
    @Published var matchState: MatchManagerState = .unauthenticated
    @Published var lastErrorMessage: String?
    @Published var isHost: Bool = false
    @Published var currentRound: Int = 0
    @Published var randomSeed: UInt64?
    @Published var raceStarted: Bool = false
    @Published var playerTimes: [String: TimeInterval] = [:]
    
    var match: GKMatch?
    var readyPlayersIDs = Set<String>()
    var hasSentGameStart = false
    private var readyHeartbeatTimer: Timer?
    private var hostStartTimeoutTimer: Timer?
    
    var onRoundStartReceived: ((Int, UInt64, TimeInterval) -> Void)?
    var onPlayerUpdateReceived: ((GameMessage) -> Void)?
    var onPlayerFinishedReceived: ((GameMessage) -> Void)?
    var onFinalResultsReceived: (([RaceResult]) -> Void)?
    var onPresentViewController: ((UIViewController) -> Void)?
    var onStartSolo: (()-> Void)?
    var onStartMultiplayer: (@MainActor () -> Void)?

    
    // MARK: Authentication
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = {
            [weak self] vc, error in
                guard let self = self else { return }
                
                if let vc = vc {
                    self.onPresentViewController?(vc)
                    return
                    
                }
                
                if error != nil {
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.lastErrorMessage = error?.localizedDescription
                        self.matchState = .unauthenticated
                    }
                    return
                }
                
                if GKLocalPlayer.local.isAuthenticated {
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.matchState = .authenticated
                        GKLocalPlayer.local.register(self)
                    }
                }
        }
    }
    
    // MARK: Match Lifecycle
    func startMatch(mode: MatchMode){
        let request = GKMatchRequest()

        switch mode {
        case .quickMatch (let playerCount):
            request.minPlayers = 2
            request.maxPlayers = playerCount
        case .inviteFriend (let playerCount):
            request.minPlayers = 2
            request.maxPlayers = playerCount
        }
        
        request.inviteMessage = "Join me in a Astrocat!"
        
        let viewController = GKMatchmakerViewController(matchRequest: request)
        guard let vc = viewController else { return }
        vc.matchmakerDelegate = self
        
        onPresentViewController?(vc)
    }
    
    func leaveMatch(){
        
    }
    
    func localPlayerFinished(time: TimeInterval){
        
    }
    
    // MARK: Ready Heartbeat
    func startReadyHeartbeat(){
        guard readyHeartbeatTimer == nil, !hasSentGameStart else { return }
        readyHeartbeatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                @MainActor [weak self] in
                self?.sendReadyHeartbeat()
            }
        }
    }
    
    func sendReadyHeartbeat(){
        let localID = GKLocalPlayer.local.gamePlayerID
        readyPlayersIDs.insert(localID)
        send(GameMessage.playerReady(senderID: localID), with: .reliable)
    }
    
    // MARK: Host Start Logic
    func tryStartIfHost(){
        guard isHost, match != nil, !hasSentGameStart else { return }
        
        scheduleHostStartTimeout()
        
        let expectedCount = (match?.players.count ?? 0) + 1
        if readyPlayersIDs.count >= expectedCount && match?.expectedPlayerCount == 0 {
            beginMatchStartBroadcast()
        }
        
    }
    
    private func scheduleHostStartTimeout(){
        guard hostStartTimeoutTimer == nil else { return }
        
        hostStartTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false){ [weak self] _ in
            Task { @MainActor [weak self] in
                self?.forceStartIfHost()
            }

        }
    }
    
    private func forceStartIfHost() {
        guard isHost, !hasSentGameStart else { return }
        guard let match = match, !match.players.isEmpty else { return }
        beginMatchStartBroadcast()
    }
    
    private func beginMatchStartBroadcast() {
        let seed = UInt64.random(in: 0...UInt64.max)
        self.randomSeed = seed
        hasSentGameStart = true
        matchState = .inGame
        send(GameMessage.gameStart(randomSeed: seed), with: .reliable)
        
        onStartMultiplayer?()
    }
    
    
    // MARK: Sending Messages
    private func send(_ message: GameMessage, with mode: GKMatch.SendDataMode){
        guard let match = match else {return}
        do {
            let data = try JSONEncoder().encode(message)
            try match.sendData(toAllPlayers: data, with: mode)
        } catch {
            print("[MatchSystem] send error: \(error)")        }
    }
    
    // MARK: GKMatchDelegate
    nonisolated func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer){
        
        Task {
            @MainActor in
            guard let message = try? JSONDecoder().decode(GameMessage.self, from: data) else {return}
            
            switch message.messageType {
            case .gameStart:
                randomSeed = message.randomSeed
                matchState = .inGame
                onStartMultiplayer?()
            case .playerReady:
                if !readyPlayersIDs.contains(player.gamePlayerID){
                    readyPlayersIDs.insert(player.gamePlayerID)
                }
                tryStartIfHost()
            default:
                break
            }
        }
        
    }
    
    nonisolated func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState){
        
    }
    
    nonisolated func match(_ match: GKMatch, didFailWithError error: Error?){
        
    }
    
    // MARK: GKLocalPlayerListener
    nonisolated func player(_ player: GKPlayer, didAccept invite: GKInvite){
        
    }
    
    // MARK: GKMatchMakerViewControllerDelegate
    nonisolated func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        
    }
    
    nonisolated func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error) {
    }
    
    nonisolated func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        Task {
            @MainActor in
            viewController.dismiss(animated: true)
            self.match = match
            match.delegate = self
            readyPlayersIDs.removeAll()
            hasSentGameStart = false

            let allPlayers = match.players + [GKLocalPlayer.local]
            let sortedIDs = allPlayers.map { $0.gamePlayerID }.sorted()
            self.isHost = sortedIDs.first == GKLocalPlayer.local.gamePlayerID
            
            matchState = .inLobby
            startReadyHeartbeat()
        }
    }
    
}
