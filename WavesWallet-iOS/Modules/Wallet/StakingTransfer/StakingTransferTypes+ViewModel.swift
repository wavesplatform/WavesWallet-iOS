//
//  StakingTransferTypes+Data.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

extension StakingTransfer.ViewModel {
    
    static func inputField(title: String,
                           hasError: Bool,
                           asset: DomainLayer.DTO.Asset,
                           amount: Money?) -> StakingTransfer.ViewModel.Row {
        
        let inputState: BalanceInputField.State = {
            
            let currency: DomainLayer.DTO.Balance.Currency = .init(title: asset.name,
                                                                   ticker: asset.ticker)
            
            if let amount = amount, amount.amount > 0 {
                return .balance(DomainLayer.DTO.Balance.init(currency: currency,
                                                             money: amount))
            } else {
                return .empty(asset.precision,
                              .init(title: asset.name,
                                    ticker: asset.ticker))
            }
        }()
        
        let style: BalanceInputField.Style = hasError == true ? .error : .normal
        
        let input = BalanceInputField.Model.init(style: style,
                                                 state: inputState)
        
        let title: NSAttributedString = .amountAttributedString(title: title)
        
        let inputField: StakingTransferInputFieldCell.Model =
                .init(title: title,
                      balance: input)
        
        return .inputField(inputField)
    }
    
    static func error(title: String) -> StakingTransfer.ViewModel.Row {
        return .error(StakingTransferErrorCell.Model(title: title))
    }
    
    static func button(title: String,
                       status: BlueButton.Model.Status) -> StakingTransfer.ViewModel.Row {
        
        let button = StakingTransferButtonCell.Model(title: title,
                                                     status: status)

        return .button(button)
    }
}

private extension NSAttributedString {
 
    static func amountAttributedString(title: String) -> NSAttributedString {
        
        let string: NSMutableAttributedString = NSMutableAttributedString(string: title)
        
        string.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                             NSAttributedString.Key.foregroundColor: UIColor.basic500],
                            range: NSRange(location: 0,
                                           length: string.length))
        
        return string
    }
}
