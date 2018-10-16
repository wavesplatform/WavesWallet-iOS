//
//  WavesReceiveInvoiceViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesReceiveInvoiceViewController: BaseAmountViewController {

    @IBOutlet weak var viewContainerAsset: UIView!
    @IBOutlet weak var iconAsset: UIImageView!
    @IBOutlet weak var labelAsset: UILabel!
    @IBOutlet weak var iconFav: UIImageView!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelSelectAsset: UILabel!
    @IBOutlet weak var labelAssetCryptoName: UILabel!
    
    @IBOutlet weak var buttonContinue: UIButton!
    
    var selectedAsset : String = ""
    var isValidAmount = false

    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainerAsset.addTableCellShadowStyle()
        setupAssetState()
        setupButtonContinue()
    }

    @IBAction func continueTapped(_ sender: Any) {
        view.endEditing(true)
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "WavesReceiveLoadingViewController") as! WavesReceiveLoadingViewController
        controller.isWavesAddress = true
        controller.showInController(view.superview!.firstAvailableViewController())
    }
    
    @IBAction func selectAssetTapped(_ sender: Any) {

    }
    
    override func amountTapped(_ sender: UIButton) {
        super.amountTapped(sender)
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonContinue()
    }
    
    override func amountChange() {
        super.amountChange()
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonContinue()
    }
    
    func setupAssetState() {
        
        let isSelectAsset = selectedAsset.count > 0
        labelValue.isHidden = !isSelectAsset
        iconFav.isHidden = !isSelectAsset
        labelAsset.isHidden = !isSelectAsset
        iconAsset.isHidden = !isSelectAsset
        labelAssetCryptoName.isHidden = !isSelectAsset
        labelSelectAsset.isHidden = isSelectAsset
        
        if isSelectAsset {
            labelAsset.text = selectedAsset
            let iconTitle = DataManager.logoForCryptoCurrency(selectedAsset)
            if iconTitle.count == 0 {
                iconAsset.image = nil
                labelAssetCryptoName.text = String(selectedAsset.first!).uppercased()
                iconAsset.backgroundColor = DataManager.bgColorForCryptoCurrency(selectedAsset)
            }
            else {
                labelAssetCryptoName.text = nil
                iconAsset.image = UIImage(named: iconTitle)
            }
        }
    }
    
    func setupButtonContinue() {
        if isValidAmount && selectedAsset.count > 0 {
            buttonContinue.setupButtonActiveState()
        }
        else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
    
    //MARK: - ChooseAssetViewControllerDelegate
    
    func chooseAssetViewControllerDidSelectAsset(_ asset: String) {
        selectedAsset = asset
        setupButtonContinue()
        setupAssetState()
    }
    
    deinit {
        print(classForCoder, #function)
    }
}
