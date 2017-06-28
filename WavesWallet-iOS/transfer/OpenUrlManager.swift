//
//  OpenUrlManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 25/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

class OpenUrlManager {
    static var openUrl: URL?
    
    class func parseUrlParams(openUrl: URL?) -> (String, String?, String?, String?)? {
        if let url = openUrl
            , let urlScheme = url.scheme, urlScheme == "waves"
            , let address = url.host, Address.isValidAddress(address: address) {

            var assetId: String?
            var amount: String?
            var attachment: String?
            if let c = URLComponents(url: url, resolvingAgainstBaseURL: false)
                , let items = c.queryItems{
                for i in items {
                    if i.name == "asset", let v = i.value {
                        assetId = v
                    } else if i.name == "amount", let v = i.value {
                        amount = v
                    } else if i.name == "attachment", let v = i.value {
                        attachment = v
                    }
                }
            }
            return (address, assetId, amount, attachment)
        } else {
            return nil
        }
    }
    
    class func getOpenUrlParams() -> (String, String?, String?, String?)? {
        return parseUrlParams(openUrl: openUrl)
    }
    
    class func createUrl(address: String, assetId: String?, amount: String?) -> URL? {
        var queryItems = [URLQueryItem]()
        if let assetId = assetId, !assetId.isEmpty { queryItems += [URLQueryItem(name: "asset", value: assetId)] }
        if let amount = amount, !amount.isEmpty { queryItems += [URLQueryItem(name: "amount", value: amount)] }
        return URLComponents(string: "waves://\(address)").flatMap{ c in
            var q = c
            q.queryItems = queryItems
            return q.url
        }
    }
}
