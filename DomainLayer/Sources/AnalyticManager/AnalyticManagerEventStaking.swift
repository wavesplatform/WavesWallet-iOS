//
//  AnalyticManagerEventStaking.swift
//  DomainLayer
//
//  Created by rprokofev on 31.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public enum AnalyticManagerEventStaking: AnalyticManagerEventInfo {
    
    public typealias AssetsIds = [String]
    
    public enum Social {
        case vk
        case facebok
        case twitter
        
        var name: String {
            switch self {
            case .vk: return "vk"
            case .twitter: return "twitter"
            case .facebok: return "facebook"
            }
        }
    }
    
    case landingFAQTap
    case landingStart
    case mainFAQTap
    case mainShareTap(Social)
    case mainDepositTap
    case mainWithdrawTap
    case mainTradeTap
    case mainBuyTap
    case mainPayoutsHistoryTap
    case depositSendTap(amount: Int64, assetTicker: String)
    case withdrawSendTap(amount: Int64, assetTicker: String)
    case cardSendTap(amount: Int64, assetTicker: String)
    case cardSuccess(amount: Int64, assetTicker: String)
    case depositSuccess(amount: Int64, assetTicker: String)
    case withdrawSuccess(amount: Int64, assetTicker: String)
    case depositSuccessViewDetails
    case withdrawSuccessViewDetails
    
    public var name: String {
        
        switch self {
        case .landingFAQTap: return "Staking Landing FAQ Tap"
        case .landingStart: return "Staking Landing Start"
        case .mainFAQTap: return "Staking Main FAQ Tap"
        case .mainShareTap: return "Staking Main Share Tap"
        case .mainDepositTap: return "Staking Main Deposit Tap"
        case .mainWithdrawTap: return "Staking Main Withdraw Tap"
        case .mainTradeTap: return "Staking Main Trade Tap"
        case .mainBuyTap: return "Staking Main Buy Tap"
        case .mainPayoutsHistoryTap: return "Staking Main Payouts History Tap"
        case .depositSendTap: return "Staking Deposit Send Tap"
        case .depositSuccessViewDetails: return "Staking Deposit Success View Details"
        case .withdrawSendTap: return "Staking Withdraw Send Tap"
        case .withdrawSuccessViewDetails: return "Staking Withdraw Success View Details"
            
        case .depositSuccess: return "Staking Deposit Success"
        case .withdrawSuccess: return "Staking Withdraw Success"
            
        case .cardSendTap: return "Staking Card Send Tap"
        case .cardSuccess: return "Staking Card Success"
        }
        
    }
    
    public var params: [String : String] {
        switch self {
            
        case let .mainShareTap(social):
            return ["to": social.name]
        case let .depositSendTap(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
        case let .withdrawSendTap(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
        case let .cardSendTap(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
        case let .cardSuccess(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
        case let .depositSuccess(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
        case let .withdrawSuccess(amount, assetTicker):
            return ["amount": "\(amount)", "asset": assetTicker]
            
        default:
            return [:]
        }
    }
}
