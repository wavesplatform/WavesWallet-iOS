//
//  NetworkManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 17.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: NSObject
{
    class private func getRequestWithPath(path: String, parameters: Dictionary <String, Any>?, complete: @escaping ( _ completeInfo: Any?, _ errorMessage: String?) -> Void)  {
        
        Alamofire.request("https://marketdata.wavesplatform.com/api/" + path, parameters : parameters)
            
            .responseJSON { response in
                
                if response.error != nil {
                    complete(nil, response.error?.localizedDescription)
                }
                else {
                    
                    if let dict = response.result.value as? NSDictionary {
                        if dict["status"] as? String == "error" {
                            complete (nil, dict["message"] as? String)
                        }
                        else {
                            complete (response.result.value, nil)
                        }
                    }
                    else {
                        complete (response.result.value, nil)
                    }
                }
        }
    }
    
    class func getCandles(amountAsset : String, priceAsset : String, timeframe : Int, from : Date, to : Date, complete: @escaping (_ completeInfo: NSArray?, _ errorMessage: String?) -> Void) {
        
        let dateFrom = String.init(format: "%0.f", from.timeIntervalSince1970 * 1000)
        let dateTo =  String.init(format: "%0.f", to.timeIntervalSince1970 * 1000)
        
        getRequestWithPath(path: "candles/\(amountAsset)/\(priceAsset)/\(timeframe)/\(dateFrom)/\(dateTo)", parameters: nil) { (info : Any?, errorMessage: String?) in
        
            complete(info as? NSArray, errorMessage)
        }
    }
}
