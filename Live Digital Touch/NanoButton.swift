//
//  NanoButton.swift
//  Live Digital Touch
//
//  Created by Ayden Panhuyzen on 2018-04-30.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class NanoButton: UIButton {
    private static let backgroundColour = UIColor(white: 0.17, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        backgroundColor = NanoButton.backgroundColour
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        setTitleColor(.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = NanoButton.backgroundColour.withAlphaComponent(0.75)
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.backgroundColor = NanoButton.backgroundColour
                }
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = NanoButton.backgroundColour.withAlphaComponent(isEnabled ? 1 : 0.35)
        }
    }
    
}
