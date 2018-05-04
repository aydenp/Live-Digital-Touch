//
//  MatchmakingManager.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import GameKit

class MatchmakingManager {
    
    private var request: GKMatchRequest {
        let request = GKMatchRequest()
        request.maxPlayers = 2
        return request
    }
    
    func getMatchmakingViewController(for invite: GKInvite? = nil) -> GKMatchmakerViewController? {
        if let invite = invite {
            return GKMatchmakerViewController(invite: invite)
        }
        return GKMatchmakerViewController(matchRequest: request)
    }
    
}
