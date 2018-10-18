//
//  FirstInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ShortInfoPageView: UIView {

    struct Model {
        let title: String
        let detail: String
        let firstImage: UIImage?
        let secondImage: UIImage?
        let thirdImage: UIImage?
        let fourthImage: UIImage?
    }
    
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    
    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 58, titleLeading: 16, titleTrailing: 16)
        } else if Platform.isIphoneX {
            setupAllConstraints(titleTop: 92, titleLeading: 24, titleTrailing: 24)
        } else {
            setupAllConstraints(titleTop: 68, titleLeading: 24, titleTrailing: 24)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat, titleTrailing: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        titleTrailingConstraint.constant = titleTrailing
    }
}

extension ShortInfoPageView: ViewConfiguration {
    
    func update(with model: ShortInfoPageView.Model) {
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: InfoPagesViewControllerConstants.titleAttributes)
        detailLabel.attributedText = NSAttributedString(string: model.detail, attributes: InfoPagesViewControllerConstants.textAttributes)
        
        firstImageView.image = model.firstImage
        secondImageView.image = model.secondImage
        thirdImageView.image = model.thirdImage
        fourthImageView.image = model.fourthImage
        
        updateConstraints()
        
    }
    
}
