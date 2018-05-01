//
//  GameCenterHelper.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import GameKit

class GameCenterHelper {
    static let shared = GameCenterHelper()
    private var _observers = NSHashTable<AnyObject>.weakObjects()
    
    enum AuthenticationState {
        case authenticated, notAuthenticated, failed(Error?)
        
        var isAuthenticated: Bool {
            switch self {
            case .authenticated: return true
            default: return false
            }
        }
    }
    
    func authenticateUser() {
        GKLocalPlayer.localPlayer().authenticateHandler = { (viewController, error) in
            if let viewController = viewController {
                self.authenticationState = .notAuthenticated
                self.notifyObservers { $0.authenticateGameCenter(with: viewController) }
            } else if let error = error {
                self.authenticationState = .failed(error)
            } else {
                self.authenticationState = .authenticated
            }
        }
    }
    
    var authenticationState = AuthenticationState.notAuthenticated {
        didSet {
            self.notifyObservers { $0.gameCenterAuthenticationState(changedTo: authenticationState) }
        }
    }
    
    // MARK: - Observer Watching
    
    func add(observer: GameCenterObserver) {
        _observers.add(observer as AnyObject)
    }
    
    func remove(observer: GameCenterObserver) {
        _observers.remove(observer as AnyObject)
    }
    
    private func notifyObservers(with block: (GameCenterObserver) -> Void) {
        let observers = _observers.allObjects.compactMap { $0 as? GameCenterObserver }
        observers.forEach { block($0) }
    }
}

protocol GameCenterObserver: class {
    func gameCenterAuthenticationState(changedTo authenticationState: GameCenterHelper.AuthenticationState)
    func authenticateGameCenter(with viewController: UIViewController)
}
