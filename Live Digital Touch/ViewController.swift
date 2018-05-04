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
        // Do any additional setup after loading the view, typically from a nib.
        updateInviteButton()
        GameCenterHelper.shared.add(observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GameCenterHelper.shared.authenticateUser()
    }
    
    func updateInviteButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.leadButton.alpha = 0
        }) { (completed) in
            guard completed else { return }
            switch GameCenterHelper.shared.authenticationState {
            case .authenticated:
                self.leadButton.setTitle("Invite Peer", for: .normal)
            case .failed(_), .notAuthenticated:
                self.leadButton.setTitle("Sign in to Game Center", for: .normal)
            case .loading:
                self.leadButton.setTitle("Signing in…", for: .normal)
            }
            self.leadButton.isEnabled = !GameCenterHelper.shared.authenticationState.isBusy
            UIView.animate(withDuration: 0.1, animations: {
                self.leadButton.alpha = 1
            })
        }
    }

    @IBAction func leadButtonTapped(_ sender: Any) {
        if GameCenterHelper.shared.authenticationState.isAuthenticated {
            presentMatchmakingViewController()
        } else {
            GameCenterHelper.shared.authenticateUser()
        }
    }
    
    private func presentMatchmakingViewController(for invite: GKInvite? = nil) {
        guard let matchmakingVC = matchmakingHelper.getMatchmakingViewController(for: invite) else { return }
        matchmakingVC.matchmakerDelegate = self
        present(matchmakingVC, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowSession", let session = sender as? Session, let sessionVC = segue.destination as? SessionViewController else { return }
        sessionVC.session = session
    }
    
}

// MARK: - Game Center Observer
extension ViewController: GameCenterObserver {
    func authenticateGameCenter(with viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func gameCenterAuthenticationState(changedTo authenticationState: GameCenterHelper.AuthenticationState) {
        updateInviteButton()
    }
    
    func gameCenterAccepted(invite: GKInvite) {
        presentedViewController?.dismiss(animated: false, completion: nil)
        presentMatchmakingViewController(for: invite)
    }
}

// MARK: - Matchmaker View Controller Delegate
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
