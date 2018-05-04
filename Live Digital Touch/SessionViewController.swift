//
//  SessionViewController.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class SessionViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var canvasHelper: DTSCanvasViewControllerHelper!
    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        session.delegate = self
        if !session.isConnected {
            activityIndicator.startAnimating()
        }
        setupCanvasViewController()
    }
    
    deinit {
        // Disconnect gracefully before removing from memory
        session.disconnect()
    }
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .all
    }
    
    private func setupCanvasViewController() {
        canvasHelper = DTSCanvasViewControllerHelper()
        canvasHelper.sendDelegate = self
        
        // Add colour picker
        let colourPicker = (NSClassFromString("ETHorizontalColorPicker") as! UIView.Type).init()
        canvasHelper.colorPicker = colourPicker
        
        // Remove replay button
        canvasHelper.replayButton?.removeFromSuperview()
        canvasHelper.replayButton = nil
        
        // Hide canvas unless connected
        canvasHelper.view.isHidden = !session.isConnected
        
        // Add canvas to view
        addChildViewController(canvasHelper.viewController)
        canvasHelper.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasHelper.view.frame = view.bounds
        view.insertSubview(canvasHelper.view, at: 0)
        canvasHelper.viewController.didMove(toParentViewController: self)
        
        // Adjust colour picker layout
        colourPicker.removeFromSuperview()
        view.addSubview(colourPicker)
        colourPicker.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = colourPicker.widthAnchor.constraint(equalToConstant: 330)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
        colourPicker.heightAnchor.constraint(equalToConstant: 26).isActive = true
        let safeBottomConstraint = colourPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        safeBottomConstraint.priority = .defaultLow
        safeBottomConstraint.isActive = true
        colourPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        colourPicker.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        colourPicker.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        colourPicker.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
    }

    private func dismiss(with error: Error?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Session Disconnected", message: error?.localizedDescription ?? "The session partner disconnected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        session.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
}

extension SessionViewController: SessionDelegate {
    func sessionConnected(changedTo connected: Bool) {
        if connected {
            activityIndicator.stopAnimating()
            canvasHelper.view.isHidden = false
        } else {
            dismiss(with: nil)
        }
    }
    
    func sessionDisconnected(with error: Error?) {
        dismiss(with: error)
    }
    
    func sessionRetrieved(data: Data) {
        guard let object = (NSClassFromString("ETMessage") as? NSObjectProtocol)?.perform("unarchive:", with: data).takeUnretainedValue() as? NSObject else { return }
        object.setValue(UUID().uuidString, forKey: "_identifier")
        canvasHelper.didReceive(message: object, from: self)
    }
}

extension SessionViewController: DTSCanvasViewControllerHelperSendDelegate {
    @objc func canvasViewController(_ canvasViewController: NSObject, sendMessage message: NSObject) {
        guard let data = message.perform("archive")?.takeUnretainedValue() as? Data else { return }
        session.send(data: data)
    }
}
