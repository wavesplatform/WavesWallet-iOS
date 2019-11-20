//
//  Menu.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum Menu: AnalyticManagerEventInfo {
        
        case wavesMenuPage
        
        case wavesMenuWhitepaper
        
        case wavesMenuTermsAndConditions
        
        case wavesMenuSupport
        
        case wavesMenuGithub
        
        case wavesMenuTelegram
        
        case wavesMenuDiscord
        
        case wavesMenuTwitter
        
        case wavesMenuReddit
        
        case wavesMenuForum
        
        case wavesMenuFAQ
        
        case wavesMenuMedium

        public var name: String {
            
            switch self {
            case .wavesMenuPage:
                return "Waves Menu Page"
                
            case .wavesMenuWhitepaper:
                return "Waves Menu Whitepaper"
                
            case .wavesMenuTermsAndConditions:
                return "Waves Menu Terms and Conditions"
                
            case .wavesMenuSupport:
                return "Waves Menu Support"
                
            case .wavesMenuGithub:
                return "Waves Menu Github"
                
            case .wavesMenuTelegram:
                return "Waves Menu Telegram"
                
            case .wavesMenuDiscord:
                return "Waves Menu Discord"
            
            case .wavesMenuTwitter:
                return "Waves Menu Twitter"
                
            case .wavesMenuReddit:
                return "Waves Menu Reddit"
            
            case .wavesMenuForum:
                return "Waves Menu Forum"
                
            case .wavesMenuFAQ:
                return "Waves Menu FAQ"
                
            case .wavesMenuMedium:
                return "Waves Menu Medium"
            }
        }
        
        public var params: [String : String] {
            switch self {
                
            default:
                return [:]
            }
        }
    }
}
