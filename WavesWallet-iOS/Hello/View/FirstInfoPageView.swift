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
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTopConstraint: NSLayoutConstraint!
    
    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 24, titleLeading: 12, titleTrailing: 12, textTrailing: 12, textLeading: 12, btnBot: 14, btnLeading: 12, btnTrailing: 12, textTop: 24)
        }
        else {
            setupAllConstraints(titleTop: 44, titleLeading: 16, titleTrailing: 16, textTrailing: 16, textLeading: 16, btnBot: 24, btnLeading: 16, btnTrailing: 16, textTop: 44)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat, titleTrailing: CGFloat, textTrailing: CGFloat, textLeading: CGFloat, btnBot: CGFloat, btnLeading: CGFloat, btnTrailing: CGFloat, textTop: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        titleTrailingConstraint.constant = titleTrailing
        textTrailingConstraint.constant = textTrailing
        textLeadingConstraint.constant = textLeading
        btnBotConstraint.constant = btnBot
        btnLeadingConstraint.constant = btnLeading
        btnTrailingConstraint.constant = btnTrailing
        textTopConstraint.constant = textTop
    }
}
