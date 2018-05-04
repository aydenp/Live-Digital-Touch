//
//  DTSCanvasViewControllerHelper.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-05-03.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class DTSCanvasViewControllerHelper {
    private static let canvasClass = NSClassFromString("DTSCanvasViewController") as! UIViewController.Type
    let viewController = canvasClass.init()
    
    subscript(key: String) -> Any? {
        get { return viewController.value(forKey: key) }
        set { viewController.setValue(newValue, forKey: key) }
    }
    
    // MARK: - View Controller Manipulation
    
    var view: UIView {
        get { return viewController.view }
        set { viewController.view = newValue }
    }
    
    var sendDelegate: DTSCanvasViewControllerHelperSendDelegate? {
        get { return self["_sendDelegate"] as? DTSCanvasViewControllerHelperSendDelegate }
        set { self["_sendDelegate"] = newValue }
    }
    
    func didReceive(message: NSObject, from dataSource: NSObject) {
        viewController.perform(Selector(("dataSource:didReceiveSessionMessage:")), with: dataSource, with: message)
    }
}

@objc protocol DTSCanvasViewControllerHelperSendDelegate: class {
    @objc func canvasViewController(_ canvasViewController: NSObject, sendMessage message: NSObject)
}
