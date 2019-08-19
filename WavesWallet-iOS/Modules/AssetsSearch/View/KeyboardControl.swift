//
//  KeyboardControl.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//
import UIKit
import Extensions

private enum Constants {
    static let durationAnimation: TimeInterval = 0.24
}

protocol KeyboardControlDelegate: AnyObject {
    
    func keyboardControlDidTapKeyboardButton(hasDissmissKeyboardButton: Bool)
}

final class KeyboardControl: UIView, NibLoadable, NibOwnerLoadable {
    
    struct Model {
        let title: String
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var keyboardButton: UIButton!
    
    var hasDissmissKeyboardButton: Bool = true {
        didSet {
            if hasDissmissKeyboardButton {
                flipUpDissmissButton()
            } else {
                flipDownDissmissButton()
            }
        }
    }
    
    var delegate: KeyboardControlDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    @objc @IBAction func handlerDissmissButton() {                
        delegate?.keyboardControlDidTapKeyboardButton(hasDissmissKeyboardButton: hasDissmissKeyboardButton)
    }
    
    private func flipUpDissmissButton() {
        
        UIView.animate(withDuration: Constants.durationAnimation, delay: 0, options: [], animations: {
            self.keyboardButton.layer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
        }, completion: nil)
    }
    
    private func flipDownDissmissButton() {
        UIView.animate(withDuration: Constants.durationAnimation, delay: 0, options: [], animations: {
            self.keyboardButton.layer.setAffineTransform(CGAffineTransform(scaleX: 1, y: -1))
        }, completion: nil)
    }
}

extension KeyboardControl: ViewConfiguration {
    
    func update(with model: KeyboardControl.Model) {
        titleLabel.text = model.title
    }
}
