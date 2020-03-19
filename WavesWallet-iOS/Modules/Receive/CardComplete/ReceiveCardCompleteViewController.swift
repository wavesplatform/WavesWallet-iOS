//
//  ReceiveCardCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
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
        removeTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Receivecardcomplete.Label.redirectToIndacoin
        labelSubtitle.text = Localizable.Waves.Receivecardcomplete.Label.afterPaymentUpdateBalance
        buttonOkey.setTitle(Localizable.Waves.Receivecardcomplete.Button.okay, for: .normal)
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        let assetDetailsViewController = navigationController?.viewControllers.first {
            $0.classForCoder == AssetDetailViewController.classForCoder()
        }
        
        if let assetVc = assetDetailsViewController {
            navigationController?.popToViewController(assetVc, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
