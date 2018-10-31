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

final class AliasWithoutViewController: UIViewController, Localization {
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
        setupLocalization()
    }

    @IBAction func handlerTapCreateButton(sender: Any) {
        delegate?.aliasWithoutUserTapCreateNewAlias()
    }

    func setupLocalization() {
        createButton.setTitle(Localizable.Waves.Aliaseswithout.View.Info.Button.create, for: .normal)
        titleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.title
        subtitleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.subtitle
        secondSubtitleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.secondsubtitle
        feeLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.fee
    }
}
