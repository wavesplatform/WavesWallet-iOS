//
//  SweetSnackbarView.swift
//  SweetSnackbar
//
//  Created by Prokofev Ruslan on 17/10/2018.
//  Copyright © 2018 Waves. All rights reserved.
//

import UIKit

final class SweetSnackView: UIView, NibLoadable {

    @IBOutlet private var leftLayout: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var leftButton: UIButton!

    var buttonDidTap: ((UIButton) -> Void)?
    private(set) var model: SweetSnack?

    func update(model: SweetSnack) {
        self.model = model

        if let icon = model.icon {
//            leftLayout.constant = 0
//            leftButton.setImage(icon, for: .normal)
//            leftButton.isHidden = false
        } else {
//            leftLayout.constant = 16
//            leftButton.setImage(nil, for: .normal)
//            leftButton.isHidden = true
        }

        if model.subtitle != nil {
            titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }

        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        subtitleLabel.isHidden = model.subtitle == nil

        setNeedsUpdateConstraints()
    }

    @IBAction func handlerTapButton() {
        buttonDidTap?(leftButton)
    }
}

//extension SweetSnackView: ViewCalculateHeight {
//
//    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
//
////        if let icon = model.icon {
////            leftLayout.constant = 0
////            leftButton.setImage(icon, for: .normal)
////            leftButton.isHidden = false
////        } else {
////            leftLayout.constant = 16
////            leftButton.setImage(nil, for: .normal)
////            leftButton.isHidden = true
////        }
////
////        if model.subtitle != nil {
////            titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
////            subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
////        } else {
////            titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
////        }
//
//    }
//}

