//
//  CheckboxControl.swift
//  WavesWallet-iOS
//
//  Created by Mac on 12/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class CheckboxControl: UIControl {
    
    var checkBoxImageView: UIImageView!
    var emptyBoxImageView: UIImageView!
    
    private var _on: Bool = false
    var on: Bool {
        get {
            return _on
        }
        set {
            _on = newValue
            setOn(newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        checkBoxImageView = UIImageView(image: Images.Checkbox.checkboxOn.image)
        emptyBoxImageView = UIImageView(image: Images.Checkbox.checkboxOff.image)
        
        addSubview(checkBoxImageView)
        addSubview(emptyBoxImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        checkBoxImageView.frame = bounds
        emptyBoxImageView.frame = bounds
    }
    
    private func setOn(_ on: Bool) {
        checkBoxImageView.isHidden = !on
        emptyBoxImageView.isHidden = on
    }
    
}
