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
    @IBOutlet private var leftAtIconConstraint: NSLayoutConstraint!
    @IBOutlet private var leftAtSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private var iconImageView: UIImageView!

    private var isHiddenIcon: Bool = true
    private(set) var model: SweetSnack?

    override func updateConstraints() {

        leftAtIconConstraint.isActive = !isHiddenIcon
        leftAtSuperviewConstraint.isActive = isHiddenIcon

        super.updateConstraints()
    }

    func update(model: SweetSnack) {
        self.model = model

        backgroundColor = model.backgroundColor
        if let icon = model.icon {
            isHiddenIcon = false
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            isHiddenIcon = true
            iconImageView.image = nil
            iconImageView.isHidden = true
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

    func startAnimationIcon() {
        // TODO: Animation
    }

    func stopAnimationIcon() {
        // TODO: Animation
    }
}
