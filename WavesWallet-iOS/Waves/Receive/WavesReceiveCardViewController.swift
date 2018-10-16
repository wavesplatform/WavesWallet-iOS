//
//  WavesReceiveCardViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesReceiveCardViewController: BaseAmountViewController {

    @IBOutlet weak var viewContainerAsset: UIView!
    
    @IBOutlet weak var iconAsset: UIImageView!
    @IBOutlet weak var labelAsset: UILabel!
    @IBOutlet weak var iconFav: UIImageView!
    @IBOutlet weak var labelAssetValue: UILabel!
    @IBOutlet weak var labelSelectAsset: UILabel!
    @IBOutlet weak var labelAssetCryptoName: UILabel!
    
    @IBOutlet weak var buttonContinue: UIButton!
    
    var selectedAsset : String = ""
    var isValidAmount = false

    @IBOutlet weak var rightTextOffset: NSLayoutConstraint!
    @IBOutlet weak var leftTextOffset: NSLayoutConstraint!
    
    @IBOutlet weak var offsetTextField: NSLayoutConstraint!
    @IBOutlet weak var offsetViewInfo: NSLayoutConstraint!
    
    let minValue : Double = 30
    let maxValue : Double = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainerAsset.addTableCellShadowStyle()
        
        setupAssetState()
        setupButtonContinue()
        
        if Platform.isIphone5 {
            leftTextOffset.constant = 42
            rightTextOffset.constant = 8
            offsetTextField.constant = 18
            offsetViewInfo.constant = 18
        }
    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        
        view.endEditing(true)
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "WavesReceiveRedirectViewController") as! WavesReceiveRedirectViewController
        controller.isCardMode = true
        controller.showInController(view.superview!.firstAvailableViewController())
    }
    
    
    override func amountChange() {
        super.amountChange()
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value >= minValue && value <= maxValue {
                isValidAmount = true
            }
        }
        
        setupButtonContinue()
    }
    
    
    @IBAction func selectAssetTapped(_ sender: Any) {
      
    }
    
    func setupAssetState() {
        
        let isSelectAsset = selectedAsset.count > 0
        labelAssetValue.isHidden = !isSelectAsset
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
        
        setupAssetState()
        setupButtonContinue()
    }
    
    deinit {
        print(classForCoder, #function)
    }
}
