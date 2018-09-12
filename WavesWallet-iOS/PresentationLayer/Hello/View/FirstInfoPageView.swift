//
//  FirstInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class FirstInfoPageView: UIView {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTopConstraint: NSLayoutConstraint!
    
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
