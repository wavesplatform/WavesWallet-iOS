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
import TTTAttributedLabel

protocol StakingTransactionCompletedVCDelegate: AnyObject {
    
}

final class StakingTransactionCompletedVC: UIViewController {
    
    struct Model {
                
        enum Kind {
            case deposit(balance: DomainLayer.DTO.Balance)
            case withdraw(balance: DomainLayer.DTO.Balance)
            case card
        }
        
        let kind: Kind
    }
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: TTTAttributedLabel!
    @IBOutlet var successButton: UIButton!
    @IBOutlet var detailButton: UIButton!
    
    private var model: Model?
    
    var didTapSuccessButton: (() -> Void)?
    var didTapDetailButton: (() -> Void)?
    var didSelectLinkWith: ((URL) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subTitleLabel.delegate = self
        subTitleLabel.activeLinkAttributes = NSMutableAttributedString.urlAttributted()
        subTitleLabel.linkAttributes = NSMutableAttributedString.urlAttributted()
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

// MARK: ViewConfiguration

extension StakingTransactionCompletedVC: ViewConfiguration {
    
    func update(with model: Model) {
        
        self.model = model
        guard isViewLoaded else {
            return
        }
        
        self.detailButton.setTitle(Localizable.Waves.Transactioncompleted.Button.Viewdetails.title, for: .normal)
        self.successButton.setTitle(Localizable.Waves.Transactioncompleted.Button.Success.title, for: .normal)
        
        detailButton.isHidden = false
        
        
        switch model.kind {
        case .card:
            detailButton.isHidden = true
            self.titleLabel.text = Localizable.Waves.Transactioncompleted.Card.title
            
            let partUrl = Localizable.Waves.Transactioncompleted.Card.Subtitle.url
            let string = Localizable.Waves.Transactioncompleted.Card.subtitle(partUrl)
            
            let title: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
                                    
            title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                 NSAttributedString.Key.foregroundColor: UIColor.basic500],
                                range: NSRange(location: 0,
                                               length: title.length))
            
            if let range = string.nsRange(of: partUrl) {
                title.addAttributes(NSMutableAttributedString.urlAttributted(),
                                    range: range)
                
                title.addAttributes([NSAttributedString.Key.link: UIGlobalConstants.URL.support],
                                    range: range)
                
            }
        
            self.subTitleLabel.text = title
            self.subTitleLabel.addLinks(from: title)
            
        case .withdraw(let balance):
            self.titleLabel.text = Localizable.Waves.Transactioncompleted.title
            let value = Localizable.Waves.Transactioncompleted.Withdraw.subtitle(balance.displayText)
            self.subTitleLabel.text = value
                        
        case .deposit(let balance):
            self.titleLabel.text = Localizable.Waves.Transactioncompleted.title
            let value = Localizable.Waves.Transactioncompleted.Deposit.subtitle(balance.displayText)
            self.subTitleLabel.text = value
        }
    }
}


final class StakingTransactionCompletedBuilder: ModuleBuilder {
        
    func build(input: StakingTransactionCompletedVC.Model) -> StakingTransactionCompletedVC {
        
        let vc = StoryboardScene.StakingTransfer.stakingTransactionCompletedVC.instantiate()
        vc.update(with: input)
        return vc
    }
}

// MARK: TTTAttributedLabelDelegate

extension StakingTransactionCompletedVC: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        self.didSelectLinkWith?(url)
    }
}
