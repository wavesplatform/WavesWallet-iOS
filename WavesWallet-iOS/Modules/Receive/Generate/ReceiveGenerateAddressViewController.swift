//
//  ReceiveAnimationGenerateViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
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
         
    private var coordinator: ReceiveAddressCoordinator?
    var input: ReceiveGenerateAddress.DTO.GenerateType!
  
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
        removeTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.backgroundImage = nil
        showTopBarLine()
        navigationItem.titleTextAttributes = nil
        navigationItem.largeTitleTextAttributes = nil
    }
    
    private func acceptGeneratingAddress() {
        
        guard let navigationController = navigationController else { return }
        guard let type = input else { return }
        
        // TODO: The Code need will move to parent Coordinator
        coordinator = ReceiveAddressCoordinator(navigationRouter: NavigationRouter(navigationController: navigationController),
                                                generateType: type)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.simulatingCryptocurrencyTime) { [weak self] in
            self?.coordinator?.start()
        }
    }
    
    private func setupLocalication() {
        
        labelGenerate.text = Localizable.Waves.Receivegenerate.Label.generate
     
        guard let type = input else { return }
        
        switch type {
        case .cryptoCurrency(let info):
            title = Localizable.Waves.Receivegenerate.Label.yourAddress(info.asset.displayName)
            
        case .invoice(let info):
            title = Localizable.Waves.Receivegenerate.Label.yourAddress(info.assetName)
        }
    }
}
