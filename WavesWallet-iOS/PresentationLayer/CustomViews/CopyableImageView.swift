//
//  CopyableImageView.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 01/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class CopyableImageView: UIImageView {

    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.image = self.image
        UIMenuController.shared.setMenuVisible(false, animated: true)
        ImpactFeedbackGenerator.impactOccurred()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }

    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}
