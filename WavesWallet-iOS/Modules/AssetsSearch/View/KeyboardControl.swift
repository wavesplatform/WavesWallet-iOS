//
//  KeyboardControl.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//
import UIKit

protocol KeyboardControlDelegate: AnyObject {
    
    func keyboardControlDidTapDissmiss()
}

final class KeyboardControl: UIView, NibLoadable {
    
    struct Model {
        let title: String
    }
    
    @IBOutlet private var titleLabel: UILabel!
    
    var delegate: KeyboardControlDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    @objc @IBAction func handlerDissmissButton() {
        delegate?.keyboardControlDidTapDissmiss()
    }
}

extension KeyboardControl: ViewConfiguration {
    
    func update(with model: KeyboardControl.Model) {
        titleLabel.text = model.title
    }
}
