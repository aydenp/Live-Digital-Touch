//
//  Session.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import GameKit

class Session: NSObject {
    weak var delegate: SessionDelegate?
    var match: GKMatch
    
    init(match: GKMatch) {
        self.match = match
        super.init()
        match.delegate = self
        evaluateConnectionState()
    }
    
    var isConnected = false {
        didSet {
            guard isConnected != oldValue else { return }
            delegate?.sessionConnected(changedTo: isConnected)
        }
    }
    
    func disconnect() {
        match.disconnect()
        match.delegate = self
    }
    
    private func evaluateConnectionState() {
        isConnected = match.expectedPlayerCount <= 0 && !match.players.isEmpty
    }
    
    func send(data: Data) {
        _ = try? match.send(data, to: match.players, dataMode: .reliable)
    }
}


extension Session: GKMatchDelegate {
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        evaluateConnectionState()
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        delegate?.sessionDisconnected(with: error)
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        delegate?.sessionRetrieved(data: data)
    }
    
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return false
    }
}

protocol SessionDelegate: class {
    func sessionConnected(changedTo connected: Bool)
    func sessionDisconnected(with error: Error?)
    func sessionRetrieved(data: Data)
}
