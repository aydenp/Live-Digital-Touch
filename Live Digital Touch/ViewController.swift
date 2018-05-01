//
//  ViewController.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    @IBOutlet weak var leadButton: NanoButton!
    var matchmakingHelper = MatchmakingManager(), session: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        canInvite = false
        GameCenterHelper.shared.add(observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GameCenterHelper.shared.authenticateUser()
    }
    
    var canInvite = false {
        didSet {
            UIView.animate(withDuration: 0.1, animations: {
                self.leadButton.alpha = 0
            }) { (completed) in
                guard completed else { return }
                self.leadButton.setTitle(self.canInvite ? "Invite Peer" : "Sign in to Game Center", for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.leadButton.alpha = 1
                })
            }
        }
    }

    @IBAction func leadButtonTapped(_ sender: Any) {
        if canInvite {
            guard let matchmakingVC = matchmakingHelper.getMatchmakingViewController() else { return }
            matchmakingVC.matchmakerDelegate = self
            present(matchmakingVC, animated: true, completion: nil)
        } else {
            GameCenterHelper.shared.authenticateUser()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowSession", let session = sender as? Session, let sessionVC = segue.destination as? SessionViewController else { return }
        sessionVC.session = session
    }
    
}

extension ViewController: GameCenterObserver {
    func authenticateGameCenter(with viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func gameCenterAuthenticationState(changedTo authenticationState: GameCenterHelper.AuthenticationState) {
        canInvite = authenticationState.isAuthenticated
    }
}

extension ViewController: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Matchmaking Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true, completion: nil)
        let session = Session(match: match)
        performSegue(withIdentifier: "ShowSession", sender: session)
    }
}
