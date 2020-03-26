//
//  TransactionCompletedVC.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

protocol TransactionCompletedInput {
    
}

final class TransactionCompletedVC: UIViewController {
    
    struct Model {
                
        enum Kind {
            case deposit
            case withdraw
        }
        
        let kind: Kind
        let balance: DomainLayer.DTO.Balance
    }
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var successButton: UIButton!
    @IBOutlet var detailButton: UIButton!
    
    private var model: Model?
    
    var didTapSuccessButton: (() -> Void)?
    var didTapDetailButton: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let model = model {
            self.update(with: model)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAlphaShadow(alpha: 0.3, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setAlphaShadow(alpha: 0, animated: true)
    }
    
    private func setAlphaShadow(alpha: CGFloat, animated: Bool) {
        let action = {
            self.shadowView.alpha = alpha
        }
        
        if animated {
            UIView.animate(withDuration: 0.24) {
                action()
            }
        } else {
            action()
        }
    }
                    
    @IBAction func handlerTapSuccessButton() {
        self.didTapSuccessButton?()
    }
    
    @IBAction func handlerTapDetailButton() {
        self.didTapDetailButton?()
    }
}

extension TransactionCompletedVC: ViewConfiguration {
    
    func update(with model: Model) {
        
        self.model = model
        guard isViewLoaded else {
            return
        }
        
        self.titleLabel.text = Localizable.Waves.Transactioncompleted.title
        self.detailButton.setTitle(Localizable.Waves.Transactioncompleted.Button.Viewdetails.title, for: .normal)
        self.successButton.setTitle(Localizable.Waves.Transactioncompleted.Button.Success.title, for: .normal)
        
        switch model.kind {
        case .withdraw:
            let value = Localizable.Waves.Transactioncompleted.Withdraw.subtitle(model.balance.displayText)
            self.subTitleLabel.text = value
            
        case .deposit:
            let value = Localizable.Waves.Transactioncompleted.Deposit.subtitle(model.balance.displayText)
            self.subTitleLabel.text = value
        }
    }
}


final class TransactionCompletedBuilder: ModuleBuilder {
        
    func build(input: TransactionCompletedVC.Model) -> TransactionCompletedVC {
        
        let vc = StoryboardScene.StakingTransfer.transactionCompletedVC.instantiate()
        vc.update(with: input)
        return vc
    }
}
