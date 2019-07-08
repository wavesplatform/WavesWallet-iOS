//
//  ThirdIndoPageView.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol LongInfoPageViewDelegate: class {
    
    func longInfoPageViewDidScrollToBottom(view: LongInfoPageView)
    
}

final class LongInfoPageView: UIView {
    
    class Model {
        let title: String
        let firstDetail: String
        let secondDetail: String
        let thirdDetail: String
        let fourthDetail: String
        let firstImage: UIImage?
        let secondImage: UIImage?
        let thirdImage: UIImage?
        let fourthImage: UIImage?
        var scrolledToBottom: Bool = false
        
        init(title: String, firstDetail: String, secondDetail: String,
         thirdDetail: String,
         fourthDetail: String,
         firstImage: UIImage?,
         secondImage: UIImage?,
         thirdImage: UIImage?,
         fourthImage: UIImage?) {
            self.title = title
            self.firstDetail = firstDetail
            self.secondDetail = secondDetail
            self.thirdDetail = thirdDetail
            self.fourthDetail = fourthDetail
            self.firstImage = firstImage
            self.secondImage = secondImage
            self.thirdImage = thirdImage
            self.fourthImage = fourthImage
        }
    }
    
    weak var delegate: LongInfoPageViewDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var secondSectionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var firstTextLabel: UILabel!
    @IBOutlet private weak var secondTextLabel: UILabel!
    @IBOutlet private weak var thirdTextLabel: UILabel!
    @IBOutlet private weak var fourthTextLabel: UILabel!

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setupConstraints() {
        if Platform.isIphone5 {
            setupAllConstraints(titleTop: 58, titleLeading: 16, textTrailing: 16, secondTop: 24)
        } else if Platform.isIphoneXSeries {
            setupAllConstraints(titleTop: 92, titleLeading: 24, textTrailing: 24, secondTop: 44)
        } else {
            setupAllConstraints(titleTop: 68, titleLeading: 24, textTrailing: 24, secondTop: 24)
        }
    }
    
    private func setupAllConstraints(titleTop: CGFloat, titleLeading: CGFloat, textTrailing: CGFloat, secondTop: CGFloat) {
        titleTopConstraint.constant = titleTop
        titleLeadingConstraint.constant = titleLeading
        textTrailingConstraint.constant = textTrailing
        secondSectionTopConstraint.constant = secondTop
    }
    
    func updateOnScroll() {
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        let contentOffsetY = scrollView.contentOffset.y
        
        if contentHeight > 0 && contentHeight - height - contentOffsetY <= 0 {
            delegate?.longInfoPageViewDidScrollToBottom(view: self)
        }
        
    }

    
}

extension LongInfoPageView: ViewConfiguration {
    
    func update(with model: LongInfoPageView.Model) {
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: InfoPagesViewControllerConstants.subtitleAttributes)
        firstTextLabel.attributedText = NSAttributedString(string: model.firstDetail, attributes: InfoPagesViewControllerConstants.textAttributes)
        secondTextLabel.attributedText = NSAttributedString(string: model.secondDetail, attributes: InfoPagesViewControllerConstants.textAttributes)
        thirdTextLabel.attributedText = NSAttributedString(string: model.thirdDetail, attributes: InfoPagesViewControllerConstants.textAttributes)
        fourthTextLabel.attributedText = NSAttributedString(string: model.fourthDetail, attributes: InfoPagesViewControllerConstants.textAttributes)
        
        firstImageView.image = model.firstImage
        secondImageView.image = model.secondImage
        thirdImageView.image = model.thirdImage
        fourthImageView.image = model.fourthImage
        
        setupConstraints()
        scrollView.delegate = self

    }
    
}

extension LongInfoPageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateOnScroll()
    }
    
}
