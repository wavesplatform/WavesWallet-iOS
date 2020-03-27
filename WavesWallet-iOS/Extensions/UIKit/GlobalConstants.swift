//
//  GlobalConstants.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions

enum UIGlobalConstants {

    static let WavesTransactionFee = Money(WavesSDKConstants.WavesTransactionFeeAmount,
                                           WavesSDKConstants.WavesDecimals)

    
    static let limitPriceOrderPercent: Int = 5
    
    #if DEBUG
    static let accountNameMinLimitSymbols: Int = 2
    static let accountNameMaxLimitSymbols: Int = 24
    static let minLengthPassword: Int = 2
    static let minimumSeedLength = 10
    #else
    static let accountNameMinLimitSymbols: Int = 2
    static let accountNameMaxLimitSymbols: Int = 24
    static let minLengthPassword: Int = 6
    static let minimumSeedLength = 25
    #endif
    
    enum URL {
        static let termsOfUse = "https://waves.exchange/files/Terms_Of_Use_Waves.Exchange.pdf"
        static let termsOfConditions = "https://waves.exchange/files/Privacy_Policy_Waves.Exchange.pdf"
        static let medium = "https://medium.com/wavesexchange"
        static let telegram = "https://t.me/wavesexchange_announcements"
        static let support = "https://support.waves.exchange/"
        static let faq = "https://waves.exchange/faq"
        static let twitter = "https://twitter.com/Waves_Exchange"
        static let client = "https://waves.exchange/"
        static let twSharing = "https://twitter.com/share?url=https://waves.exchange/staking&text="
        static let fbSharing = "https://www.facebook.com/sharer/sharer.php?u=https://waves.exchange/staking&quote="
        static let vkSharing = "https://vk.com/share.php?url=https://waves.exchange/staking&description="
        static let stakingFaq = "https://waves.exchange/staking/faq"                
        static let advcash = "https://wallet.advcash.com/ru/login"        
    }
    
    static let supportEmail = "support@waves.exchange"
    
    
}

