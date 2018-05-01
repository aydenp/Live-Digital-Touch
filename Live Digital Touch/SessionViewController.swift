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
    var canvasViewController: UIViewController!
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
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .all
    }
    
    private func setupCanvasViewController() {
        let canvasClass = NSClassFromString("DTSCanvasViewController") as! UIViewController.Type
        canvasViewController = canvasClass.init()
        canvasViewController.setValue(self, forKey: "_sendDelegate")
        canvasViewController.view.isHidden = !session.isConnected
        
        addChildViewController(canvasViewController)
        canvasViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasViewController.view.frame = view.bounds
        view.insertSubview(canvasViewController.view, at: 0)
        canvasViewController.didMove(toParentViewController: canvasViewController)
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
            canvasViewController.view.isHidden = false
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
        canvasViewController.perform("dataSource:didReceiveSessionMessage:", with: self, with: object)
    }
}

extension SessionViewController {
    @objc func canvasViewController(_ canvasViewController: NSObject, sendMessage message: NSObject) {
        print(message)
        guard let data = message.perform("archive")?.takeUnretainedValue() as? Data else { return }
        session.send(data: data)
    }
}
