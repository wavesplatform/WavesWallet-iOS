//
//  SixthInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class SixthInfoPageView: UIView {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondSectionTopConstraint: NSLayoutConstraint!
    
    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 24, titleLeading: 12, textTrailing: 12, btnBot: 14, btnLeading: 12, btnTrailing: 12, secondTop: 24)
        }
        else {
            setupAllConstraints(titleTop: 44, titleLeading: 16,  textTrailing: 16, btnBot: 24, btnLeading: 16, btnTrailing: 16, secondTop: 44)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat,  textTrailing: CGFloat, btnBot: CGFloat, btnLeading: CGFloat, btnTrailing: CGFloat, secondTop: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        textTrailingConstraint.constant = textTrailing
        btnBotConstraint.constant = btnBot
        btnLeadingConstraint.constant = btnLeading
        btnTrailingConstraint.constant = btnTrailing
        secondSectionTopConstraint.constant = secondTop
    }
}
