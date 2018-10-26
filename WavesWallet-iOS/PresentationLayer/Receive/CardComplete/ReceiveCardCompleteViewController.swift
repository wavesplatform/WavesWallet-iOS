//
//  ReceiveCardCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveCardCompleteViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Receivecardcomplete.Label.redirectToIndacoin
        labelSubtitle.text = Localizable.Waves.Receivecardcomplete.Label.afterPaymentUpdateBalance
        buttonOkey.setTitle(Localizable.Waves.Receivecardcomplete.Button.okay, for: .normal)
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        if let assetVc = navigationController?.viewControllers.first(where: {$0.classForCoder == AssetViewController.classForCoder()}) {
            navigationController?.popToViewController(assetVc, animated: true)
        }
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
