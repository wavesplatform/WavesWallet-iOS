//
//  AnalyticManagerProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public enum AnalyticManagerEvent {
    case leasing(Leasing)
    case createAlias(CreateAlias)
    case dex(Dex)
    case walletAsset(WalletAsset)
    case tokenBurn(TokenBurn)
    case walletStart(WalletStart)
    case newUser(NewUser)
}

public protocol AnalyticManagerEventInfo {
    var name: String { get }
    var params: String { get }
}

public protocol AnalyticManagerProtocol {
    func trackEvent(_ event: AnalyticManagerEvent)
}

//MARK - Event params
public extension AnalyticManagerEvent {
    
    var name: String {
        switch self {
        case .leasing(let leasing):
            return leasing.rawValue
            
        case .createAlias(let alias):
            return alias.rawValue
            
        case .dex(let dex):
            return dex.name
            
        case .walletAsset(let walletAsset):
            return walletAsset.name
            
        case .tokenBurn(let tokenBurn):
            return tokenBurn.rawValue
            
        case .walletStart(let walletStart):
            return walletStart.name
            
        case .newUser(let user):
            return user.rawValue
        }
    }
    
    var params: [String : String] {
        switch self {
            
        case .dex(let dex):
            return dex.params
            
        case .walletAsset(let walletAsset):
            return walletAsset.params
            
        case .walletStart(let walletStart):
            return walletStart.params
            
        default:
            return [:]
        }
    }
}

//MARK: - Leasing
public extension AnalyticManagerEvent {
    public enum Leasing: String {
        
        /* Нажата кнопка «Start Lease» на экране Wallet. */
        case leasingStartTap = "Leasing Start Tap"
        
        /* Нажата кнопка «Start Lease» на экране с заполненными полями. */
        case leasingSendTap = "Leasing Send Tap"
        
        /* Нажата кнопка «Confirm» на экране подтверждения лизинга. */
        case leasingConfirmTap = "Leasing Confirm Tap"
    }
}

//MARK: - CreateAlias
public extension AnalyticManagerEvent {
    public enum CreateAlias: String {
        
        /* Нажата кнопка «Create a new alias» на экране профайла. */
        case createProfile = "Alias Create Profile"
        
        /* Нажата кнопка «Create a new alias» на экране визитки. */
        case aliasCreateVcard = "Alias Create Vcard"
    }
}

//MARK: - TokenBurn
public extension AnalyticManagerEvent {
    public enum TokenBurn: String {
        
        /* Нажата кнопка «Token Burn» на экране ассета. */
        case tap = "Burn Token Tap"
        
        /* Нажата кнопка «Burn» на экране с заполненными полями. */
        case continueTap = "Burn Token Continue Tap"
        
        /* Нажата кнопка «Burn» на экране подтверждения. */
        case confirmTap = "Burn Token Confirm Tap"
    }
}

//MARK: - NewUser
public extension AnalyticManagerEvent {
    public enum NewUser: String {
        
        /* Проставлены 3 чекбокса с условиями использования и нажата кнопка "Begin". */
        case confirm = "New User Confirm"
    }
}
