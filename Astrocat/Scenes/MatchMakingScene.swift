//
//  MatchMakingScene.swift
//  Astrocat
//
//  Created by Arya on 13/05/26.
//

import SwiftUI
import GameKit

struct MatchMakerView: UIViewControllerRepresentable {
//    @ObservedObject var matchManager: MatchManager
    
    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        request.inviteMessage = "Join me in JumpRace!"
        
        let vc = GKMatchmakerViewController(matchRequest: request)
        if let vc = vc {
            vc.matchmakerDelegate = matchManager
        }
        return vc ?? GKMatchmakerViewController()
    }
    
    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {}
}
