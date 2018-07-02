//
//  WavesReceiveСryptocurrencyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesReceiveCryptocurrencyViewController: UIViewController, ChooseAssetViewControllerDelegate {

    @IBOutlet weak var viewContainerAsset: UIView!
    
    @IBOutlet weak var viewAssetInfo: UIView!
    @IBOutlet weak var labelSelectAsset: UILabel!
    @IBOutlet weak var labelAsset: UILabel!
    @IBOutlet weak var iconLogo: UIImageView!
    @IBOutlet weak var iconFav: UIImageView!
    @IBOutlet weak var labelAssetValue: UILabel!
    @IBOutlet weak var labelAssetCryptoName: UILabel!
    
    @IBOutlet weak var buttonContinue: UIButton!
    
    var selectedAsset : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainerAsset.addTableCellShadowStyle()
        setupButtonContinue()
        setupAssetState()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "WavesReceiveLoadingViewController") as! WavesReceiveLoadingViewController
        controller.showInController(view.superview!.firstAvailableViewController())
    }
    
    @IBAction func selectAssetTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChooseAssetViewController") as! ChooseAssetViewController
        controller.delegate = self
        controller.selectedAsset = selectedAsset
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func setupAssetState() {
        
        let isSelectAsset = selectedAsset.count > 0
        labelAssetValue.isHidden = !isSelectAsset
        iconFav.isHidden = !isSelectAsset
        labelAsset.isHidden = !isSelectAsset
        iconLogo.isHidden = !isSelectAsset
        labelAssetCryptoName.isHidden = !isSelectAsset
        labelSelectAsset.isHidden = isSelectAsset

        viewAssetInfo.isHidden = !isSelectAsset

        if isSelectAsset {
            labelAsset.text = selectedAsset
            let iconTitle = DataManager.logoForCryptoCurrency(selectedAsset)
            if iconTitle.count == 0 {
                iconLogo.image = nil
                labelAssetCryptoName.text = String(selectedAsset.first!).uppercased()
                iconLogo.backgroundColor = DataManager.bgColorForCryptoCurrency(selectedAsset)
            }
            else {
                labelAssetCryptoName.text = nil
                iconLogo.image = UIImage(named: iconTitle)
            }
        }
    }
    
    func setupButtonContinue() {
        if selectedAsset.count > 0 {
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
