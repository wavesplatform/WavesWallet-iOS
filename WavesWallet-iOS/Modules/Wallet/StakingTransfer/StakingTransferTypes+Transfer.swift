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
    
    func error(by error: StakingTransfer.DTO.InputData.Transfer.Error,
               kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return errorForWithdraw(by: error)
            
        case .deposit:
            return errorForDeposit(by: error)
            
        case .card:
            return .skeletonBalance
        }
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
}

