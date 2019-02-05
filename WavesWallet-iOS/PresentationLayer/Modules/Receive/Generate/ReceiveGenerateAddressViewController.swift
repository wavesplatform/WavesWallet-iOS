//
//  ReceiveAnimationGenerateViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFeedback

private enum Constants {
    static let simulatingCryptocurrencyTime: TimeInterval = 1
}

final class ReceiveGenerateAddressViewController: UIViewController {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelGenerate: UILabel!
    
    var input: ReceiveGenerate.DTO.GenerateType!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        viewContainer.addTableCellShadowStyle()
        setupLocalication()
        acceptGeneratingAddress()
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backgroundImage = UIImage()
        hideTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.backgroundImage = nil
        showTopBarLine()
        navigationItem.titleTextAttributes = nil
    }
    
    private func acceptGeneratingAddress() {
        
        guard let type = input else { return }
        switch type {
        case .cryptoCurrency(let displayInfo):
            showCryptocurrencyAddressInfo(displayInfo)
        
        case .invoice(let displayInfo):
            showInvoceAddressInfo(displayInfo)
        }
    }
    
    private func setupLocalication() {
        
        labelGenerate.text = Localizable.Waves.Receivegenerate.Label.generate
     
        guard let type = input else { return }
        
        switch type {
        case .cryptoCurrency(let info):
            title = Localizable.Waves.Receivegenerate.Label.yourAddress(info.assetName)
            
        case .invoice(let info):
            title = Localizable.Waves.Receivegenerate.Label.yourAddress(info.assetName)
        }
    }
    
    private func showCryptocurrencyAddressInfo(_ info: ReceiveCryptocurrency.DTO.DisplayInfo) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.simulatingCryptocurrencyTime) {
            
            let addressInfo = ReceiveAddress.DTO.Info(assetName: info.assetName,
                                                      address: info.address,
                                                      icon: info.icon,
                                                      qrCode: info.address,
                                                      invoiceLink: nil,
                                                      isSponsored: false)
            
            let vc = ReceiveAddressModuleBuilder().build(input: addressInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showInvoceAddressInfo(_ info: ReceiveInvoice.DTO.DisplayInfo) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.simulatingCryptocurrencyTime) {
            
            let addressInfo = ReceiveAddress.DTO.Info(assetName: info.assetName,
                                                      address: info.address,
                                                      icon: info.icon,
                                                      qrCode: info.invoiceLink,
                                                      invoiceLink: info.invoiceLink,
                                                      isSponsored: info.isSponsored)
            
            let vc = ReceiveAddressModuleBuilder().build(input: addressInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
