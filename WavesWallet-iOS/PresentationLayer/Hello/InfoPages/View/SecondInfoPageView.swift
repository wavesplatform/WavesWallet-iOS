//
//  SecondInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SecondInfoPageView: UIView {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var btnBotConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLanguages()
    }

    func setupLanguages() {
        titleLabel.text = Localizable.Hello.Page.Info.head
        detailLabel.text = Localizable.Hello.Page.Info.Second.detail
        nextBtn.setTitle(Localizable.Hello.Page.Info.Button.next, for: .normal)
    }

    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 24, titleLeading: 12, titleTrailing: 12, btnBot: 14, textTop: 24)
        }
        else {
            setupAllConstraints(titleTop: 44, titleLeading: 16, titleTrailing: 16, btnBot: 24, textTop: 44)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat, titleTrailing: CGFloat, btnBot: CGFloat, textTop: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        titleTrailingConstraint.constant = titleTrailing
        btnBotConstraint.constant = btnBot
        textTopConstraint.constant = textTop
    }
}
