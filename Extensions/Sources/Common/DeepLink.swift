//
//  DeepLink\.swift
//  Extensions
//
//  Created by rprokofev on 15.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public enum DeepLink {}

public extension DeepLink {
    
    #if DEBUG
    static let scheme: String = "waves://"
    #elseif TEST
    static let scheme: String = "waves-test://"
    #else
    static let scheme: String = "waves-dev://"
    #endif
    
//    com.wavesplatform.waveswallet.dev.widget.marketpulse
    
    static let widgetSettings: String = "\(DeepLink.scheme)widgetsettings"
}


//waves://app

