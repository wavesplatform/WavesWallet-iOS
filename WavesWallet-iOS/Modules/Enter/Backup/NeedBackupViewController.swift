//
//  NewAccountSecretPhraseViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let topLogoOffset: CGFloat = 118
}

protocol NeedBackupModuleOutput: AnyObject {
    func userCompletedInteract(skipBackup: Bool)
}

final class NeedBackupViewController: UIViewController {
    @IBOutlet private weak var topLogoOffset: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private var bullets: [UILabel]!
    @IBOutlet private weak var firstLineLabel: UILabel!
    @IBOutlet private weak var secondLineLabel: UILabel!
    @IBOutlet private weak var thirdLineLabel: UILabel!
    
    @IBOutlet private weak var backUpNowButton: UIButton!
    @IBOutlet private weak var doItLaterButton: UIButton!

    weak var output: NeedBackupModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.shadowImage = UIImage()
        navigationItem.backgroundImage = UIImage()        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.largeTitleDisplayMode = .never
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = Images.userimgBackup100.image
        
        titleLabel.textAlignment = .center
        titleLabel.font = .calloutSemibold
        titleLabel.text = Localizable.Waves.Needbackupscreen.title
        
        detailsLabel.numberOfLines = 0
        detailsLabel.font = .caption2Regular
        detailsLabel.text = Localizable.Waves.Needbackupscreen.pleaseLearnTheImportant
        
        bullets.forEach {
            $0.font = .titleH2
            $0.textColor = .submit300
            $0.text = Localizable.Waves.Needbackupscreen.bullet
        }
        
        do {
            let attrString = NSMutableAttributedString(string: Localizable.Waves.Needbackupscreen.afterCreatingAccountCopySeed,
                                                       attributes: [.font: UIFont.caption2Regular])
            let copySeedString = Localizable.Waves.Needbackupscreen.Aftercreatingaccountcopyseed.copySeed
            let copySeedRange = attrString.mutableString.range(of: copySeedString)
            attrString.addAttribute(.font, value: UIFont.caption2Semibold, range: copySeedRange)
            
            let safeString = Localizable.Waves.Needbackupscreen.Aftercreatingaccountcopyseed.safe
            let safeRange = attrString.mutableString.range(of: safeString)
            attrString.addAttribute(.font, value: UIFont.caption2Semibold, range: safeRange)
            
            firstLineLabel.attributedText = attrString
            firstLineLabel.numberOfLines = 0
        }
        
        do {
            secondLineLabel.font = .caption2Regular
            secondLineLabel.text = Localizable.Waves.Needbackupscreen.ifYouLoseSeedThenYouLoseMoney
            secondLineLabel.numberOfLines = 0
        }
        
        do {
            let attrString = NSMutableAttributedString(string: Localizable.Waves.Needbackupscreen.neverTellAnyoneSeed,
                                                       attributes: [.font: UIFont.caption2Regular])
            let neverRange = attrString.mutableString.range(of: Localizable.Waves.Needbackupscreen.Nevertellanyoneseed.never)
            attrString.addAttribute(.font, value: UIFont.captionSemibold, range: neverRange)
            
            thirdLineLabel.attributedText = attrString
            thirdLineLabel.numberOfLines = 0
        }

        backUpNowButton.setTitle(Localizable.Waves.Backup.Needbackup.Button.backupnow, for: .normal)
        doItLaterButton.setTitle(Localizable.Waves.Backup.Needbackup.Button.doitlater, for: .normal)
        backUpNowButton.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        backUpNowButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }
    
    @IBAction func laterTapped(_ sender: Any) {
        output?.userCompletedInteract(skipBackup: true)
    }
    
    @IBAction func backupNowTapped(_ sender: Any) {
        output?.userCompletedInteract(skipBackup: false)
    }
}
