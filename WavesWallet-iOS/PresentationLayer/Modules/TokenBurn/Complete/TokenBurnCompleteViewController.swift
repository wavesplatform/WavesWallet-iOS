//
//  TokenBurnCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TokenBurnCompleteViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
   
    struct Input {
        let assetName: String
        let isFullBurned: Bool
        let delegate: TokenBurnTransactionDelegate?
        let amount: Money
    }
    
    var input: Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true

        labelTitle.text = Localizable.Waves.Tokenburn.Label.transactionIsOnWay
        labelSubtitle.text = Localizable.Waves.Tokenburn.Label.youHaveBurned + " " + input.amount.displayText + " " + input.assetName
        buttonOkey.setTitle(Localizable.Waves.Tokenburn.Button.okey, for: .normal)
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        if input.isFullBurned {
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            if let vc = navigationController?.viewControllers.first(where: {$0.isKind(of: AssetDetailViewController.classForCoder())}) {
                
                input.delegate?.tokenBurnDidSuccessBurn(amount: input.amount)
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }

}
