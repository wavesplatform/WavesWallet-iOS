//
//  CreateNewAliasViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol AliasWithoutViewControllerDelegate: AnyObject {
    func aliasWithoutUserTapCreateNewAlias()
}

final class AliasWithoutViewController: UIViewController {
    weak var delegate: AliasWithoutViewControllerDelegate?

    @IBOutlet private var createButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var secondSubtitleLabel: UILabel!
    @IBOutlet private var feeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        createButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
//        createButton.setTitle(Localizable.Waves.Changepassword.Button.Confirm.title, for: .normal)
    }

    @IBAction func handlerTapCreateButton(sender: Any) {
        delegate?.aliasWithoutUserTapCreateNewAlias()
    }
}
