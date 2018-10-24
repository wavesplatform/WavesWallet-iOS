//
//  SendCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SendCompleteViewController: UIViewController {

    struct Input {
        let assetName: String
        let amount: Money
        let address: String
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    @IBOutlet private weak var labelSaveAddress: UILabel!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var viewSaveAddress: UIView!
    
    var input: Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        labelAddress.text = input.address
    }
    

    @IBAction private func confirmTapped(_ sender: Any) {
     
        
    }
    
    @IBAction private func addContact(_ sender: Any) {
    
    }
    
    private func setupLocalization() {
        
        labelSaveAddress.text = Localizable.SendComplete.Label.saveThisAddress
        buttonOkey.setTitle(Localizable.SendComplete.Button.okey, for: .normal)
        labelTitle.text = Localizable.SendComplete.Label.transactionIsOnWay
        
        let amount = input.amount.displayText + " " + input.assetName
        labelSubtitle.text = Localizable.SendComplete.Label.youHaveSent + " " + amount
    }
}
