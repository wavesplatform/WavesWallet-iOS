//
//  FirstInfoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit

protocol ShortInfoPageViewDelegate: AnyObject {
    func shortInfoPageViewDidScrollToBottom(view: ShortInfoPageView)
}

final class ShortInfoPageView: UIView {
    class Model {
        let title: String
        let detail: String
        let firstImage: UIImage?
        let secondImage: UIImage?
        let thirdImage: UIImage?
        let fourthImage: UIImage?
        var scrolledToBottom: Bool = false
        
        init(title: String,
             detail: String,
             firstImage: UIImage?,
             secondImage: UIImage?,
             thirdImage: UIImage?,
             fourthImage: UIImage?) {
            self.title = title
            self.detail = detail
            self.firstImage = firstImage
            self.secondImage = secondImage
            self.thirdImage = thirdImage
            self.fourthImage = fourthImage
        }
    }
    
    weak var delegate: ShortInfoPageViewDelegate?
    
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var firstImageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!
    @IBOutlet private weak var thirdImageView: UIImageView!
    @IBOutlet private weak var fourthImageView: UIImageView!
    
    @IBOutlet private weak var contentView: UIView!
    
    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 58, titleLeading: 16, titleTrailing: 16)
        } else if Platform.isIphoneXSeries {
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
    
    func updateOnScroll() {
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        let contentOffsetY = scrollView.contentOffset.y
        
        if contentHeight > 0, contentHeight - height - contentOffsetY <= imageViewBottomConstraint.constant {
            delegate?.shortInfoPageViewDidScrollToBottom(view: self)
        }
    }
}

extension ShortInfoPageView: ViewConfiguration {
    func update(with model: ShortInfoPageView.Model) {
        titleLabel.attributedText = NSAttributedString(string: model.title,
                                                       attributes: InfoPagesViewControllerConstants.titleAttributes)
        detailLabel.attributedText = NSAttributedString(string: model.detail,
                                                        attributes: InfoPagesViewControllerConstants.textAttributes)
        
        firstImageView.image = model.firstImage
        secondImageView.image = model.secondImage
        thirdImageView.image = model.thirdImage
        fourthImageView.image = model.fourthImage
        
        setupConstraints()
        scrollView.delegate = self
        
        setNeedsLayout()
        layoutIfNeeded()
        updateOnScroll()
    }
}

extension ShortInfoPageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateOnScroll()
    }
}
