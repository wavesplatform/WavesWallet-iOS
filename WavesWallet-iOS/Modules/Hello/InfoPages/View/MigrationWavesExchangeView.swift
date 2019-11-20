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

//TODO: MOVE URL TO GLOBAL CONSTANTS
private enum Constants {
    static let buttonDeltaWidth: CGFloat = 24
}

final class MigrationWavesExchangeView: UIView, InfoPagesViewDisplayingProtocol {
    
    struct Model {}
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var logoOldImageView: UIImageView!
    @IBOutlet private weak var logoNewImageView: UIImageView!
    
    @IBOutlet private weak var logoOldCenterY: NSLayoutConstraint!
    @IBOutlet private weak var logoNewCenterY: NSLayoutConstraint!

    weak var delegate: MigrationWavesExchangeDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = Localizable.Waves.Migration.Wavesexchange.View.title
        descriptionLabel.text = Localizable.Waves.Migration.Wavesexchange.View.title
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    func infoPagesViewWillDisplayDisplaying() {
        
        logoNewCenterY.constant = -self.logoNewImageView.frame.height * 0.5
        logoOldCenterY.constant = self.logoNewImageView.frame.height * 0.5
        
        UIView.animateKeyframes(withDuration: 0.40, delay:0.3, options: [.calculationModeCubicPaced], animations: {
                
            self.logoNewImageView.alpha = 1
            self.layoutIfNeeded()
            self.logoOldImageView.transform = CGAffineTransform(scaleX: 0.84, y: 0.84)
         }) { (_) in
          
            self.logoNewImageView.superview?.bringSubviewToFront(self.logoNewImageView)
            self.logoNewCenterY.constant = 0
            self.logoOldCenterY.constant = 0
            UIView.animateKeyframes(withDuration: 0.40, delay: 0, options: [.calculationModeCubicPaced], animations: {
                self.logoOldImageView.alpha = 0
                self.layoutIfNeeded()
            }) { (_) in
                self.delegate?.migrationWavesExchangeAnimationEnd()
            }
         }
    }
    
    func infoPagesViewDidEndDisplaying() {
        self.delegate?.migrationWavesExchangeAnimationEnd()
        logoNewCenterY.constant = -self.logoNewImageView.frame.height
        logoOldCenterY.constant = 0
        self.logoOldImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.logoNewImageView.alpha = 0
        self.logoOldImageView.alpha = 1
        self.logoOldImageView.superview?.bringSubviewToFront(self.logoOldImageView)
    }
}

extension MigrationWavesExchangeView: ViewConfiguration {
    
    func update(with model: Model) {}
}
