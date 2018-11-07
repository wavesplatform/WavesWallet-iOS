//
//  ReceiveTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Receive {
    enum ViewModel {}
    enum DTO {}
}

extension Receive.DTO {
    static func urlFromPath(_ path: String, params: Dictionary<String, String>) -> String {
        var url = path
        for key in params.keys {
            if let value = params[key] {
                if (url as NSString).range(of: "?").location == NSNotFound {
                    url.append("?")
                }
                
                if url.last != "?" {
                    url.append("&")
                }
                url.append(key + "=" + value)
            }
        }
        return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? url
    }
}

extension Receive.ViewModel {
    
    enum State: Int {
        case cryptoCurrency
        case invoice
        case card
    }
 
}
