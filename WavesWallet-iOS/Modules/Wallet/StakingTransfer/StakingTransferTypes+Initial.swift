//
//  StakingTransferTypes+Initial.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

extension StakingTransfer.State.UI {
    
    static func initialState(kind: StakingTransfer.DTO.Kind) -> StakingTransfer.State.UI {
        
        switch kind {
        case .card:
            return initialStateCard()
            
        case .deposit:
            return initialStateDeposit()
            
        case .withdraw:
            return initialStateWithdraw()
        }
    }
    
    static func initialStateCard() -> StakingTransfer.State.UI {
                        
        let title = Localizable.Waves.Staking.Transfer.Card.title
        
        return StakingTransfer.State.UI(sections: [],
                                        title: title,
                                        action: .update)
    }
    
    static func initialStateDeposit() -> StakingTransfer.State.UI {
        
        let title = Localizable.Waves.Staking.Transfer.Deposit.title
        
        return StakingTransfer.State.UI(sections: [],
                                        title: title,
                                        action: .update)
    }
    
    static func initialStateWithdraw() -> StakingTransfer.State.UI {
        
        let title = Localizable.Waves.Staking.Transfer.Withdraw.title
        
        return StakingTransfer.State.UI(sections: [],
                                        title: title,
                                        action: .update)
    }
}

extension StakingTransfer.DTO.Card {
    
    func inputField(inputCard: StakingTransfer.DTO.InputCard?) -> StakingTransfer.ViewModel.Row {
        
        let inputState: BalanceInputField.State = {
            
            let currency: DomainLayer.DTO.Balance.Currency = .init(title: asset.name,
                                                                   ticker: asset.ticker)
            
            if let inputCard = inputCard, let amount = inputCard.amount, amount.amount > 0 {
                return .balance(DomainLayer.DTO.Balance.init(currency: currency,
                                                             money: amount))
            } else {
                return .empty(asset.precision,
                              .init(title: asset.name,
                                    ticker: asset.ticker))
            }
        }()
        
        let style: BalanceInputField.Style = inputCard?.error != nil ? .error : .normal
        
        let input = BalanceInputField.Model.init(style: style,
                                                 state: inputState)
        
        let title: NSAttributedString = .amountAttributedString()
        
        let inputField: StakingTransferInputFieldCell.Model =
                .init(title: title,
                      balance: input)
        
        return .inputField(inputField)
    }
    
    func error(inputCard: StakingTransfer.DTO.InputCard?) -> StakingTransfer.ViewModel.Row? {
        
        let error: StakingTransferErrorCell.Model? = {
            
            switch inputCard?.error {
            case .minAmount:
                let title = Localizable.Waves.Staking.Transfer.Error.minamount(self.maxAmount.displayText)
                return StakingTransferErrorCell.Model.init(title: title)
                
            case .maxAmount:
                let title = Localizable.Waves.Staking.Transfer.Error.maxamount(self.maxAmount.displayText)
                return StakingTransferErrorCell.Model.init(title: title)
            default:
                return nil
            }
        }()
        
        if let error = error {
            return .error(error)
        } else {
            return nil
        }
    }
    
    func sections(inputCard: StakingTransfer.DTO.InputCard?) -> [StakingTransfer.ViewModel.Section] {
                
        let assistanceButton: StakingTransfer.DTO.AssistanceButton = .max
        
        let buttons: StakingTransferScrollButtonsCell.Model =
            .init(buttons: [assistanceButton.rawValue])
                    
        let description: StakingTransferDescriptionCell.Model = .init(attributedString: .descriptionCardAttributedString(minAmount: minAmount, maxAmount: maxAmount))
        
                
        let error: StakingTransfer.ViewModel.Row? = self.error(inputCard: inputCard)
        
        let inputField = self.inputField(inputCard: inputCard)
                
        var rows: [StakingTransfer.ViewModel.Row] = .init()
        
        rows.append(inputField)
        
        if let error = error {
            rows.append(error)
        }
                        
        rows.append(contentsOf: [.scrollButtons(buttons),
                                 .description(description)])
        
                    
        let button = self.button(status: .disabled)
        rows.append(button)
        
        let section: StakingTransfer.ViewModel.Section =
            .init(rows: rows)
        
        return [section]
    }
    
    func button(status: BlueButton.Model.Status) -> StakingTransfer.ViewModel.Row {
        
        let buttonTitle = Localizable.Waves.Staking.Transfer.Card.title
        
        let button = StakingTransferButtonCell.Model.init(title: buttonTitle,
                                                          status: status)
        
        return .button(button)
    }
}

private extension NSAttributedString {
 
    static func amountAttributedString() -> NSAttributedString {
        
        let string = Localizable.Waves.Staking.Transfer.Card.Cell.Input.title
        let title: NSMutableAttributedString = NSMutableAttributedString(string: string)
        
        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                             NSAttributedString.Key.foregroundColor: UIColor.basic500],
                            range: NSRange(location: 0,
                                           length: title.length))
        
        return title
    }
    
    static func descriptionCardAttributedString(minAmount: DomainLayer.DTO.Balance,
                                                maxAmount: DomainLayer.DTO.Balance) -> NSAttributedString {
        
        let part4Url = Localizable.Waves.Staking.Transfer.Card.Cell.Description.Title.Part4.url
        var string = Localizable.Waves.Staking.Transfer.Card.Cell.Description.Title.part1
        string += "\n\n"
        string += Localizable.Waves.Staking.Transfer.Card.Cell.Description.Title.part2
        string += "\n\n"
        string += Localizable.Waves.Staking.Transfer.Card.Cell.Description.Title.part3(minAmount.displayText,
                                                                                       maxAmount.displayText)
        string += "\n\n"
        string += Localizable.Waves.Staking.Transfer.Card.Cell.Description.Title.part4(part4Url)
        
        let title: NSMutableAttributedString = NSMutableAttributedString(string: string)
        
                                
        title.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                             NSAttributedString.Key.foregroundColor: UIColor.basic500],
                            range: NSRange(location: 0,
                                           length: title.length))
        
        if let range = string.nsRange(of: part4Url) {
            title.addAttributes(NSMutableAttributedString.urlAttributted(),
                                range: range)
            
            title.addAttributes([NSAttributedString.Key.link: UIGlobalConstants.URL.support],
                                range: range)
            
        }
            
        return title
    }
}
//            let url = URL.init(string: "HTTP://ya.ru")!
//
//            let string = NSMutableAttributedString(string: fullText)
//
//
//            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.basic500,
//                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)],
//                                 range: NSRange.init(location: 0,
//                                                     length: string.length))
//
//            string.addAttributes([NSAttributedString.Key.link: url], range: fullText.nsRange(of: "support")!)
//
