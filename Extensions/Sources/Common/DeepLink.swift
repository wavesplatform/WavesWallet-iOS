//
//  DeepLink\.swift
//  Extensions
//
//  Created by rprokofev on 15.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public struct DeepLink {
    public let source: String
    public let url: URL
    
    public init(source: String, url: URL) {
        self.source = source
        self.url = url
    }
}

public extension DeepLink {
    
    #if DEBUG
    static let scheme: String = "waves-dev://"
    #elseif TEST
    static let scheme: String = "waves-test://"
    #else
    static let scheme: String = "waves://"
    #endif
    
    static let widgetSettings: String = "\(DeepLink.scheme)widgetsettings"
}
