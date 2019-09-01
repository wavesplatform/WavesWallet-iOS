//
//  ConfirmRequestStatusViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import DomainLayer
import Extensions

final class ConfirmRequestCompleteViewController: UIViewController {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    @IBOutlet private weak var transactionKindView: ConfirmRequestTransactionKindView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
        setupLocalization()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {

    }
    
    private func setupLocalization() {
        
        //TODO: Localization
        buttonOkey.setTitle(Localizable.Waves.Sendcomplete.Button.okey, for: .normal)
        labelTitle.text = Localizable.Waves.Sendcomplete.Label.transactionIsOnWay
    }
}

extension ConfirmRequestCompleteViewController: ViewConfiguration {
    
    func update(with model: ConfirmRequestTransactionKindView.Model) {
        transactionKindView.update(with: model)
    }
}
