//
//  StakingTransferTypes+Card.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

extension StakingTransfer.DTO.Data.Card {
    
    func inputField(input: StakingTransfer.DTO.InputData.Card?) -> StakingTransfer.ViewModel.Row {
 
        let title = Localizable.Waves.Staking.Transfer.Card.Cell.Input.title
         
         return StakingTransfer
             .ViewModel
             .inputField(title: title,
                         hasError: input?.error != nil,
                         asset: asset,
                         amount: input?.amount,
                         hasDecimal: false)
    }
    
    func error(by error: StakingTransfer.DTO.InputData.Card.Error) -> StakingTransfer.ViewModel.Row {
        
        let title: String = {
            
            switch error {
            case .minAmount:
                return Localizable.Waves.Staking.Transfer.Error.minamount(self.minAmount.displayText)
                                
            case .maxAmount:
                return Localizable.Waves.Staking.Transfer.Error.maxamount(self.maxAmount.displayText)
            }
        }()
        
        return StakingTransfer
            .ViewModel
            .error(title: title)
    }
            
    func button(status: BlueButton.Model.Status) -> StakingTransfer.ViewModel.Row {
        
        let buttonTitle = Localizable.Waves.Staking.Transfer.Card.title
        
        return StakingTransfer
            .ViewModel
            .   button(title: buttonTitle,
                    status: status)
    }
        
    func errorKind(amount: Money) -> StakingTransfer.DTO.InputData.Card.Error? {
                                                    
        let minAmount = self.minAmount.money
        let maxAmount = self.maxAmount.money
                         
        if amount > maxAmount {
            return .maxAmount
        } else if amount < minAmount {
            return .minAmount
        }
        
        return nil
    }
        
    func sections(input: StakingTransfer.DTO.InputData.Card?) -> [StakingTransfer.ViewModel.Section] {
                
        var rows: [StakingTransfer.ViewModel.Row] = .init()
                                                                
        let inputField = self.inputField(input: input)
        rows.append(inputField)
        
        if let error = input?.error {
            rows.append(self.error(by: error))
        }
                                
        let assistanceButton: StakingTransfer.DTO.AssistanceButton = .max
        
        let buttons: StakingTransferScrollButtonsCell.Model =
            .init(buttons: [assistanceButton.rawValue])
        
        let description: StakingTransferDescriptionCell.Model =
            .init(attributedString: .descriptionCardAttributedString(minAmount: minAmount, maxAmount: maxAmount))
        
        rows.append(contentsOf: [.scrollButtons(buttons),
                                 .description(description)])
                                    
        let isActive: Bool = {
            
            if let amount = input?.amount {
                return self.errorKind(amount: amount) == nil
            }
            return false
        }()
        
        let button = self.button(status: isActive == true ? .active : .disabled)
        
        rows.append(button)
                
        let section: StakingTransfer
            .ViewModel
            .Section =
            .init(rows: rows)
        
        return [section]
    }
}

private extension NSAttributedString {
 
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
