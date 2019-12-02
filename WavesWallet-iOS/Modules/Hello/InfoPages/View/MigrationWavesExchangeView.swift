//
//  InfoPageConfirmView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/6/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

protocol MigrationWavesExchangeDelegate: AnyObject {
    
    func migrationWavesExchangeAnimationEnd()
}

private enum Constants {
    static let firstAnimationDuration: TimeInterval = 0.75
    static let firstAnimationDelay: TimeInterval = 0.75
    static let secondAnimationDuration: TimeInterval = 0.75
    static let topTitlePaddingIphone5: CGFloat = 44
    static let deltaIconOffset: CGFloat = 42
}

final class MigrationWavesExchangeView: UIView, InfoPagesViewDisplayingProtocol {
    
    struct Model {}
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var logoOldImageView: UIImageView!
    @IBOutlet private weak var logoNewImageView: UIImageView!
        
    @IBOutlet private weak var titlePositionTop: NSLayoutConstraint!
    @IBOutlet private weak var logoOldCenterX: NSLayoutConstraint!
    @IBOutlet private weak var logoNewCenterX: NSLayoutConstraint!
    
    weak var delegate: MigrationWavesExchangeDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = Localizable.Waves.Migration.Wavesexchange.View.title
        descriptionLabel.text = Localizable.Waves.Migration.Wavesexchange.View.description
        
        if Platform.isIphone5 {
            titlePositionTop.constant = Constants.topTitlePaddingIphone5
        }
    }
    
    func infoPagesViewWillDisplayDisplaying() {

        logoNewCenterX.constant = frame.size.width / 2 + Constants.deltaIconOffset
        layoutIfNeeded()
        
        logoNewCenterX.constant = 0
        logoOldCenterX.constant = -self.logoOldImageView.frame.width * 0.7
        
        UIView.animateKeyframes(withDuration: Constants.firstAnimationDuration, delay:Constants.firstAnimationDelay, options: [.calculationModeCubicPaced], animations: {
                      
            self.logoNewImageView.alpha = 1
            self.layoutIfNeeded()
            self.logoOldImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (_) in
        
            self.logoNewImageView.superview?.bringSubviewToFront(self.logoNewImageView)
            self.logoNewCenterX.constant = 0
            self.logoOldCenterX.constant = 0

            UIView.animateKeyframes(withDuration: Constants.secondAnimationDuration, delay: 0, options: [.calculationModeCubicPaced], animations: {
                self.logoNewImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.layoutIfNeeded()
                self.logoOldImageView.alpha = 0
            }) { (_) in
              self.delegate?.migrationWavesExchangeAnimationEnd()
            }
        }
    }
    
    func infoPagesViewDidEndDisplaying() {
        
        self.delegate?.migrationWavesExchangeAnimationEnd()
        self.logoNewCenterX.constant = frame.size.width / 2 + Constants.deltaIconOffset
        self.logoOldCenterX.constant = 0
        self.logoOldImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.logoNewImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.logoNewImageView.alpha = 0
        self.logoOldImageView.alpha = 1
        self.logoOldImageView.superview?.bringSubviewToFront(self.logoOldImageView)
    }

}

extension MigrationWavesExchangeView: ViewConfiguration {
    
    func update(with model: Model) {}
}
