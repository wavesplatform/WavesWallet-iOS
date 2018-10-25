//
//  DexCompleteOrderViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCompleteOrderViewController: UIViewController {

    @IBOutlet private weak var labelTitleLocalization: UILabel!
    @IBOutlet private weak var labelTimeLocalization: UILabel!
    @IBOutlet private weak var labelPriceLocalization: UILabel!
    @IBOutlet private weak var labelAmountLocalization: UILabel!
    @IBOutlet private weak var labelStatusLocalization: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var buttonOkey: UIButton!
    
    
    var input: DexCreateOrder.DTO.Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBgBlueImage()
        setupLocalization()
        setupInfo()
    }
}

//MARK: - Actions
private extension DexCompleteOrderViewController {
    
    @IBAction func okeyTapped(_ sender: Any) {

    }
}

//MARK: - Setup

private extension DexCompleteOrderViewController {
    
    func setupInfo() {
        labelPrice.text = input.price.displayText
        labelAmount.text = input.amount.displayText
        labelStatus.text = Localizable.Waves.Dexcompleteorder.Label.open
        labelStatus.textColor = input.orderType == .sell ? .error500 : .submit400
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        labelTime.text = dateFormatter.string(from: input.time)
        
    }
    
    func setupLocalization() {
        labelTitleLocalization.text = Localizable.Waves.Dexcompleteorder.Label.orderIsCreated
        labelTimeLocalization.text = Localizable.Waves.Dexcompleteorder.Label.time
        labelStatusLocalization.text = Localizable.Waves.Dexcompleteorder.Label.status
        labelPriceLocalization.text = Localizable.Waves.Dexcompleteorder.Label.price
        labelAmountLocalization.text = Localizable.Waves.Dexcompleteorder.Label.amount
        
        buttonOkey.setTitle(Localizable.Waves.Dexcompleteorder.Button.okey, for: .normal)
    }
}
