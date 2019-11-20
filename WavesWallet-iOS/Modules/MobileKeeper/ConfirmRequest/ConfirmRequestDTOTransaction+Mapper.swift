//
//  ConfirmRequestDTOTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import Extensions
import DomainLayer

extension ConfirmRequest.DTO.Transaction  {

    var transactionKindViewModel: ConfirmRequestTransactionKindView.Model {
        return ConfirmRequestTransactionKindView.Model.init(title: titleTransactionKindViewModel,
                                                            image: iconTransactionKindViewModel,
                                                            info: infoTransactionKindViewModel)
    }
    
    var feeAsset: DomainLayer.DTO.Asset {
        
        switch self {
        case .data(let tx):
            return tx.feeAsset
            
        case .invokeScript(let tx):
            return tx.feeAsset
            
        case .transfer(let tx):
            return tx.feeAsset
        }
    }
    
    var fee: Money {
        
        switch self {
        case .data(let tx):
            return tx.fee
            
        case .invokeScript(let tx):
            return tx.fee
            
        case .transfer(let tx):
            return tx.fee
        }
    }
    
    var infoTransactionKindViewModel: ConfirmRequestTransactionKindView.Info {
        
        //TODO: Localization
        switch self {
        case .data:
            return .descriptionLabel(Localizable.Waves.Transactioncard.Title.dataTransaction)
            
        case .invokeScript:
            return .descriptionLabel(Localizable.Waves.Transactioncard.Title.scriptInvocation)
            
        case .transfer(let tx):
            return .balance(.init(balance: Balance.init(currency: .init(title: tx.asset.displayName,
                                                                        ticker: tx.asset.ticker),
                                                        money: .init(tx.amount.amount,
                                                                     tx.asset.precision)),
                                  sign: .minus,
                                  style: .small))
        }
        
    }
    
    var titleTransactionKindViewModel: String {
       
        //TODO: Localization
        switch self {
        case .data:
            return Localizable.Waves.Transactioncard.Title.entryInBlockchain
            
        case .invokeScript:
            return Localizable.Waves.Transactioncard.Title.entryInBlockchain
            
        case .transfer:
            return Localizable.Waves.Transactioncard.Title.sent
        }
    }
    
    var iconTransactionKindViewModel: UIImage {
        switch self {
        case .data:
            return Images.tData48.image
            
        case .invokeScript:
            return Images.tInvocationscript48.image
            
        case .transfer:
            return Images.tSend48.image
        }
    }
}
