//
//  DeepLink\.swift
//  Extensions
//
//  Created by rprokofev on 15.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation

public struct DeepLink {
    public let url: URL
    
    public init(url: URL) {
        self.url = DeepLinkParser.parseHttpsURLToScheme(url)
    }
}

public extension DeepLink {
    
    #if DEBUG
    static let scheme: String = "waves-dev"
    #elseif TEST
    static let scheme: String = "waves-test"
    #else
    static let scheme: String = "waves"
    #endif
    
    static let widgetSettings: String = "\(DeepLink.scheme)://widgetsettings"
    static let mobileKeeper: String = "\(DeepLink.scheme)://keeper"
    static let send: String = "\(DeepLink.scheme)://send"
    static let dex: String = "\(DeepLink.scheme)://dex"
}

public extension DeepLink {
    
    var isClientSendLink: Bool {
        return url.absoluteString.range(of: DeepLink.send) != nil
    }
    
    
    var isClientDexLink: Bool {
        return url.absoluteString.range(of: DeepLink.dex) != nil &&
            url.absoluteString.range(of: "assetId1") != nil &&
            url.absoluteString.range(of: "assetId2") != nil
    }
    
    var isMobileKeeper: Bool {
        return url.absoluteString.range(of: DeepLink.mobileKeeper) != nil
    }
}


private final class DeepLinkParser {
    
    private static let fragmentSymbol = "#"
    
    static func parseHttpsURLToScheme(_ url: URL) -> URL {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        
        guard components.scheme != DeepLink.scheme else { return url }
        guard let host = components.host else { return url }
        
        let urlString = url.absoluteString.replacingOccurrences(of: fragmentSymbol, with: "")
        let range = (urlString as NSString).range(of: host)
        if range.location != NSNotFound {
            let newUrlString = (urlString as NSString).substring(from: range.location + range.length)
            if let newUrl = URL(string: DeepLink.scheme + ":/" + newUrlString) {
                return newUrl
            }
        }
        return url
    }
}
