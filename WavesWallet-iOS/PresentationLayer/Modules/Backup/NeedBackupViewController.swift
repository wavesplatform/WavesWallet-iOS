//
//  NewAccountSecretPhraseViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let topLogoOffset: CGFloat = 118
}

protocol NeedBackupModuleOutput: AnyObject {
    func userCompletedInteract(skipBackup: Bool)
}

final class NeedBackupViewController: UIViewController {

    @IBOutlet private weak var topLogoOffset: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var backUpNowButton: UIButton!
    @IBOutlet private weak var doItLaterButton: UIButton!

    private lazy var closeItem: UIBarButtonItem = UIBarButtonItem(image: Images.topbarClose.image, style: .plain, target: self, action: #selector(closeTapped(_:)))

    weak var output: NeedBackupModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Platform.isIphone5 {
            topLogoOffset.constant = Constants.topLogoOffset
        }
        navigationItem.shadowImage = UIImage()
        navigationItem.backgroundImage = UIImage()        
        navigationItem.rightBarButtonItem = closeItem
        navigationItem.leftBarButtonItem = UIBarButtonItem()

        titleLabel.text = Localizable.Waves.Backup.Needbackup.Label.title
        detailLabel.text = Localizable.Waves.Backup.Needbackup.Label.detail
        backUpNowButton.setTitle(Localizable.Waves.Backup.Needbackup.Button.backupnow, for: .normal)
        doItLaterButton.setTitle(Localizable.Waves.Backup.Needbackup.Button.doitlater, for: .normal)
        backUpNowButton.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        backUpNowButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    @IBAction func closeTapped(_ sender: Any) {
        output?.userCompletedInteract(skipBackup: true)
    }
    
    @IBAction func laterTapped(_ sender: Any) {
        output?.userCompletedInteract(skipBackup: true)
    }
    
    @IBAction func backupNowTapped(_ sender: Any) {
        output?.userCompletedInteract(skipBackup: false)
    }
}
