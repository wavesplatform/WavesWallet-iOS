//
//  StakingTransferTypes+Withdraw.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 24.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

extension StakingTransfer.DTO.Data.Transfer {
    
    func inputFieldForWithdraw(input: StakingTransfer.DTO.InputData.Transfer?) -> StakingTransfer.ViewModel.Row {
        
        let title = Localizable.Waves.Staking.Transfer.Withdraw.Cell.Input.title
        
        return StakingTransfer
            .ViewModel
            .inputField(title: title,
                        hasError: input?.error != nil,
                        asset: asset,
                        amount: input?.amount)
    }
    
    func errorForWithdraw(by error: StakingTransfer.DTO.InputData.Transfer.Error) -> StakingTransfer.ViewModel.Row {
        
        let error: String = {
            
            switch error {
                
            case .insufficientFunds:
                return "insufficientFunds 666"
                
            case .insufficientFundsOnTax:
                return "insufficientFunds on tax 777"
            }
        }()
        
        return StakingTransfer
            .ViewModel
            .error(title: error)
    }
    
    func buttonForWithdraw(status: BlueButton.Model.Status) -> StakingTransfer.ViewModel.Row {
        
        let buttonTitle = Localizable.Waves.Staking.Transfer.Deposit.title
        
        return StakingTransfer
            .ViewModel
            .button(title: buttonTitle,
                    status: status)
    }
    
    func sectionsForWithdraw(input: StakingTransfer.DTO.InputData.Transfer?) -> [StakingTransfer.ViewModel.Section] {
        
        var rows: [StakingTransfer.ViewModel.Row] = .init()
        
        let balance = StakingTransferBalanceCell.Model(assetURL: self.asset.iconLogo,
                                                       title: Localizable.Waves.Staking.Transfer.Withdraw.title,
                                                       money: self.balance.money)
        rows.append(.balance(balance))
        
        let inputField = self.inputFieldForWithdraw(input: input)
        rows.append(inputField)
        
        if let error = input?.error {
            let error = self.errorForWithdraw(by: error)
            rows.append(error)
        }
        
        let assistanceButtons: [StakingTransfer.DTO.AssistanceButton] = [.percent100, .percent75, .percent50, .percent25]
        
        let buttons: StakingTransferScrollButtonsCell.Model =
            .init(buttons: assistanceButtons.map { $0.rawValue })
        rows.append(.scrollButtons(buttons))
        
        let fee = StakingTransferFeeInfoCell.Model(balance: self.transactionFeeBalance)
        rows.append(.feeInfo(fee))
        
        let button = self.buttonForWithdraw(status: .disabled)
        rows.append(button)
        
        let section: StakingTransfer.ViewModel.Section =
            .init(rows: rows)
        
        return [section]
    }
}
