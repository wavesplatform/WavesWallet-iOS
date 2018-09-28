//
//  DexInfoPopupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexInfoViewController: UIViewController {

    @IBOutlet weak var labelPopular: UILabel!
    @IBOutlet weak var labelAmountAssetTitle: UILabel!
    @IBOutlet weak var labelPriceAssetTitle: UILabel!
    @IBOutlet weak var labelAmountAsset: UILabel!
    @IBOutlet weak var labelPriceAsset: UILabel!
    
    @IBOutlet weak var btnCopyAmountAsset: UIButton!
    @IBOutlet weak var btnCopyPriceAsset: UIButton!
    
    var pair: DexInfoPair.DTO.Pair!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInfo()
    }
}


//MARK: - Actions

private extension DexInfoViewController {
    
    func copy(text: String, buttonAction: UIButton) {
        
        UIPasteboard.general.string = text
        
        buttonAction.isUserInteractionEnabled = false
        buttonAction.setImage(Images.checkSuccess.image, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            buttonAction.isUserInteractionEnabled = true
            buttonAction.setImage(Images.copyAddress.image, for: .normal)
        }
    }
    
    @IBAction func copyPriceAssetTapped(_ sender: Any) {
    
        copy(text: pair.priceAsset.id, buttonAction: btnCopyPriceAsset)
    }
    
    @IBAction func copyAmountAssetTapped(_ sender: Any) {
    
        copy(text: pair.amountAsset.id, buttonAction: btnCopyAmountAsset)
    }
}

//MARK: - Setup UI

private extension DexInfoViewController {
 
    func setupInfo() {
        labelAmountAssetTitle.text = Localizable.DexInfo.Label.amountAsset + " — " + pair.amountAsset.name
        labelAmountAsset.text = pair.amountAsset.id
        
        labelPriceAssetTitle.text = Localizable.DexInfo.Label.priceAsset + " — " + pair.priceAsset.name
        labelPriceAsset.text = pair.priceAsset.id
        
        labelPopular.isHidden = pair.isHidden
    }
    
    func setupLocalization() {
        labelPopular.text = Localizable.DexInfo.Label.popular
    }
}
