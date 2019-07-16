//
//  AnalyticManagerProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public enum AnalyticManagerEvent {
    
    case createANewAccount(CreateANewAccount)
    case importAccount(ImportAccount)
    case singIn(SingIn)
    case walletHome(WalletHome)
    case walletLeasing(WalletLeasing)
    case tokenBurn(TokenBurn)
    case alias(Alias)
    case dex(Dex)
    case send(Send)
    case receive(Receive)
    case wavesQuickAction(WavesQuickAction)
    case profile(Profile)
    case addressBook(AddressBook)
    case menu(Menu)
    case widgets(Widgets)
}

public protocol AnalyticManagerEventInfo {
    var name: String { get }
    var params: [String : String] { get }
}

public protocol AnalyticManagerProtocol {
    func trackEvent(_ event: AnalyticManagerEvent)
}

//MARK - Event params
extension AnalyticManagerEvent: AnalyticManagerEventInfo {
    
    public var name: String {
        switch self {
        case .createANewAccount(let model):
            return model.name
            
        case .importAccount(let model):
            return model.name
            
        case .singIn(let model):
            return model.name
            
        case .walletHome(let model):
            return model.name
            
        case .walletLeasing(let model):
            return model.rawValue
            
        case .tokenBurn(let model):
            return model.rawValue
            
        case .alias(let model):
            return model.rawValue
            
        case .dex(let model):
            return model.name
            
        case .send(let model):
            return model.name
            
        case .receive(let model):
            return model.name
            
        case .wavesQuickAction(let model):
            return model.name
            
        case .profile(let model):
            return model.name
            
        case .addressBook(let model):
            return model.name
            
        case .menu(let model):
            return model.name
            
        case .widgets(let model):
            return model.name
        }
    }
    
    public var params: [String : String] {
        switch self {
        case .createANewAccount(let model):
            return model.params
            
        case .importAccount(let model):
            return model.params
            
        case .singIn(let model):
            return model.params
            
        case .walletHome(let model):
            return model.params
            
        case .walletLeasing( _):
            return [:]
            
        case .tokenBurn( _):
            return [:]
            
        case .alias( _):
            return [:]
            
        case .dex(let model):
            return model.params
            
        case .send(let model):
            return model.params
            
        case .receive(let model):
            return model.params
            
        case .wavesQuickAction(let model):
            return model.params
            
        case .profile(let model):
            return model.params
        
        case .addressBook(let model):
            return model.params
            
        case .menu(let model):
            return model.params
            
        case .widgets(let model):
            return model.params
        }
    }
}
