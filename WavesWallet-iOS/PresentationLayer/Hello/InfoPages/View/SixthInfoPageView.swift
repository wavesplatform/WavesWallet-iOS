//
//  SixthInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SixthInfoPageView: UIView {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var btnBotConstraint: NSLayoutConstraint!
    @IBOutlet private weak var secondSectionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLanguages()
    }

    func setupLanguages() {
        headLabel.text = Localizable.Hello.Page.Info.head
        titleLabel.text = Localizable.Hello.Page.Info.Sixth.title
        detailLabel.text = Localizable.Hello.Page.Info.Sixth.detail
        nextBtn.setTitle(Localizable.Hello.Page.Info.Button.next, for: .normal)
    }

    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 24, titleLeading: 12, textTrailing: 12, btnBot: 14, secondTop: 24)
        }
        else {
            setupAllConstraints(titleTop: 44, titleLeading: 16,  textTrailing: 16, btnBot: 24, secondTop: 44)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat,  textTrailing: CGFloat, btnBot: CGFloat, secondTop: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        textTrailingConstraint.constant = textTrailing
        btnBotConstraint.constant = btnBot
        secondSectionTopConstraint.constant = secondTop
    }
}
