//
//  StakingTrasnferTypes+Deposit.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

extension StakingTransfer.DTO.Data.Deposit {
    
    func inputField(input: StakingTransfer.DTO.InputData.Deposit?) -> StakingTransfer.ViewModel.Row {

        let title = Localizable.Waves.Staking.Transfer.Deposit.Cell.Input.title
        
        return StakingTransfer
            .ViewModel
            .inputField(title: title,
                        hasError: input?.error != nil,
                        asset: asset,
                        amount: input?.amount)
    }

    func error(by error: StakingTransfer.DTO.InputData.Deposit.Error) -> StakingTransfer.ViewModel.Row {

        let error: String = {

            switch error {
            case .minAmount:
                return Localizable.Waves.Staking.Transfer.Error.minamount("self.maxAmount.displayText")

            case .maxAmount:
                return Localizable.Waves.Staking.Transfer.Error.maxamount("self.maxAmount.displayText")
            }
        }()

        return StakingTransfer
            .ViewModel
            .error(title: error)
    }
    
    func button(status: BlueButton.Model.Status) -> StakingTransfer.ViewModel.Row {
        
        let buttonTitle = Localizable.Waves.Staking.Transfer.Deposit.title
        
        return StakingTransfer
            .ViewModel
            .button(title: buttonTitle,
                    status: .disabled)
    }
    
    func sections(input: StakingTransfer.DTO.InputData.Deposit?) -> [StakingTransfer.ViewModel.Section] {
        
        var rows: [StakingTransfer.ViewModel.Row] = .init()
        
        let balance = StakingTransferBalanceCell.Model(assetURL: self.asset.iconLogo,
                                                       title: Localizable.Waves.Staking.Transfer.Deposit.title,
                                                       money: self.availableBalance.money)
        rows.append(.balance(balance))
        
        let inputField = self.inputField(input: input)                                    
        rows.append(inputField)

        if let error = input?.error {
            let error = self.error(by: error)
            rows.append(error)
        }
        
        let assistanceButtons: [StakingTransfer.DTO.AssistanceButton] = [.percent100, .percent75, .percent50, .percent25]
        
        let buttons: StakingTransferScrollButtonsCell.Model =
            .init(buttons: assistanceButtons.map { $0.rawValue })
        rows.append(.scrollButtons(buttons))
                                         
        let fee = StakingTransferFeeInfoCell.Model(balance: self.transactionFeeBalance)
        rows.append(.feeInfo(fee))
                
        let button = self.button(status: .disabled)
        rows.append(button)
        
        let section: StakingTransfer.ViewModel.Section =
            .init(rows: rows)
        
        return [section]
    }
}
