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
        addBgBlueImage()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.ReceiveCardComplete.Label.redirectToIndacoin
        labelSubtitle.text = Localizable.ReceiveCardComplete.Label.afterPaymentUpdateBalance
        buttonOkey.setTitle(Localizable.ReceiveCardComplete.Button.okay, for: .normal)
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
