//
//  StartLeasingCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class StartLeasingCompleteViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    
    var kind: StartLeasingTypes.Kind!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
        setupLocalization()
    }
    
    private func setupLocalization() {
        
        switch kind! {
        case .send(let order):
            labelSubtitle.text = Localizable.Waves.Startleasingcomplete.Label.youHaveLeased(order.amount.displayText, "WAVES")
            
        case .cancel:
            labelSubtitle.text = Localizable.Waves.Startleasingcomplete.Label.youHaveCanceledTransaction
        }
        
        labelTitle.text = Localizable.Waves.Startleasingcomplete.Label.yourTransactionIsOnWay
        buttonOkey.setTitle(Localizable.Waves.Startleasingcomplete.Button.okey, for: .normal)
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
