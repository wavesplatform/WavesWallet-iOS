//
//  ConfirmBackupStackBaseView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ConfirmBackupStackBaseView: UIView {

    func createButton(_ title: String, isBlueWord: Bool) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        let width = title.maxWidth(font: button.titleLabel!.font)
        button.frame = CGRect(x: 0, y: 0, width: width + 28, height: buttonHeight)

        if isBlueWord {
            button.layer.cornerRadius = 3
            button.backgroundColor = .submit400
            button.setTitleColor(.white, for: .normal)
        }
        else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.addTableCellShadowStyle()
        }
        
        
        return button
    }
    
    var buttonHeight: CGFloat {
        return 36
    }
    
    var lastButtonContainer : UIView {
        return subviews.last!
    }

    var buttonContainerOffset: CGFloat {
        return 14
    }
    
    func addEmptyInputContainerView(offsetY: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
        addSubview(view)
    }
    
    func addEmptyListContainerView(offsetY: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
        view.clipsToBounds = true
        addSubview(view)
    }
    
    var heightConstraint : NSLayoutConstraint {
        return constraints.first(where: {$0.firstAttribute == NSLayoutAttribute.height})!
    }
}
