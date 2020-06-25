//
//  StakingTransfer+Transfer.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 25.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import Extensions
import DomainLayer
import WavesSDK

extension StakingTransfer.DTO.Data.Transfer {
    
    func inputField(input: StakingTransfer.DTO.InputData.Transfer?,
                    kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return inputFieldForWithdraw(input: input)
            
        case .deposit:
            return inputFieldForDeposit(input: input)
            
        case .card:
            return .skeletonBalance
        }
    }    
    func error(by error: StakingTransfer.DTO.InputData.Transfer.Error) -> StakingTransfer.ViewModel.Row {
        
        let error: String = {
            
            switch error {
                
            case .insufficientFunds:
                return Localizable.Waves.Staking.Transfer.Error.insufficientfunds
                
            case .insufficientFundsOnTax:
                return Localizable.Waves.Staking.Transfer.Error.insufficientFundsOnTax
            }
        }()
        
        return StakingTransfer
            .ViewModel
            .error(title: error)
    }
    
    func button(status: BlueButton.Model.Status,
                kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return buttonForWithdraw(status: status)
            
        case .deposit:
            return buttonForDeposit(status: status)
            
        case .card:
            return .skeletonBalance
        }
    }
    
    func sections(input: StakingTransfer.DTO.InputData.Transfer?,
                  kind: StakingTransfer.DTO.Kind) -> [StakingTransfer.ViewModel.Section] {
        
        switch kind {
        case .withdraw:
            return sectionsForWithdraw(input: input)
            
        case .deposit:
            return sectionsForDeposit(input: input)
            
        case .card:
            return []
        }
    }
    
    func errorKind(amount: Money) -> StakingTransfer.DTO.InputData.Transfer.Error? {
        
        let avaliableBalanceForFee = self.avaliableBalanceForFee.money
        let transactionFeeBalance =  self.transactionFeeBalance.money
        let balance = self.balance.money
                         
        if balance.amount == 0 {
            return .insufficientFunds
        } else if amount.amount > balance.amount {
            return .insufficientFunds
         } else if avaliableBalanceForFee.amount < transactionFeeBalance.amount {
             return .insufficientFundsOnTax
         }
            
        return nil
    }
}

