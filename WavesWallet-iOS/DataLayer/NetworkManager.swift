//
//  NetworkManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 17.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import RxAlamofire

class NetworkManager: NSObject
{
    fileprivate class func parsedObjectFromResponse(_ responseObject: Any?) -> Any? {
        
        if responseObject is NSDictionary {
            
            let item = responseObject as! NSDictionary
            let newDict = NSMutableDictionary()
            
            let keys = item.allKeys;
            
            for key in keys {
                
                let info = item[key]
                
                if info is NSArray || info is NSDictionary {
                    newDict[key] = parsedObjectFromResponse(info)
                }
                else if !(info is NSNull)
                {
                    if info is String
                    {
                        if info as! String == "null"
                        {
                            continue
                        }
                    }
                    
                    newDict[key] = info
                }
            }
            
            return newDict
        }
        else if responseObject is NSArray
        {
            let array = NSMutableArray()
            
            for info in responseObject as! NSArray {
                array.add(parsedObjectFromResponse(info)!)
            }
            
            return array;
        }
        else if responseObject is NSNull {
            return nil
        }
        
        return responseObject;
    }


    private static var matcherURL: String {
        //TODO: incorrect environment
        
        return Environments.current.servers.matcherUrl.relativeString.appending("/")
    }
   
    @discardableResult fileprivate class func baseRequestWithUrl(_ url: String, method: HTTPMethod, parameters: Dictionary <String, Any>?, headers: HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping ( _ completeInfo: JSON?, _ error: ResponseTypeError?) -> Void) -> DataRequest {
        
        return Alamofire.request(url, method: method, parameters : parameters, encoding: encoding, headers: headers)
            
            .responseJSON { response in
                
                let responseCode = response.response?.statusCode ?? 0
                
                if response.error != nil {
                    
                    let error = response.error as NSError?
                    
                    if error?.code != NSURLErrorCancelled {
                        complete(nil, .init(message: response.error?.localizedDescription ?? "", code: responseCode))
                    }
                }
                else if response.response?.statusCode != 200 {
                    complete(nil, .init(message: (response.result.value as? NSDictionary)?["message"] as? String ?? "", code: responseCode))
                }
                else {
                    
                    if let dict = response.result.value as? NSDictionary {
                        if dict["status"] as? String == "error" {
                            complete (nil, .init(message:  dict["message"] as? String ?? "", code: responseCode))
                        }
                        else if dict["error"] as? String != nil {
                            complete(nil, .init(message:  dict["error"] as? String ?? "", code: responseCode))
                        }
                        else if let value = parsedObjectFromResponse(response.result.value) {
                            complete (JSON(value), nil)
                        }
                        else {
                            complete (nil, .init(message: response.result.error?.localizedDescription ?? "", code: responseCode))
                        }
                    }
                    else if let value = parsedObjectFromResponse(response.result.value) {
                        complete(JSON(value), nil)
                    }
                    else {
                        complete (nil, .init(message: response.result.error?.localizedDescription ?? "", code: responseCode))
                    }
                }
        }

    }

    @discardableResult class func postRequestWithUrl(_ url: String, parameters: Dictionary <String, Any>?, complete: @escaping ( _ completeInfo: JSON?, _ error: ResponseTypeError?) -> Void) -> DataRequest {
    
        return baseRequestWithUrl(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, complete: complete)
    }
    
    @discardableResult class func getRequestWithUrl(_ url: String, parameters: Dictionary <String, Any>?, headers: HTTPHeaders? = nil,  complete: @escaping ( _ completeInfo: JSON?, _ error: ResponseTypeError?) -> Void) -> DataRequest {

        return baseRequestWithUrl(url, method: .get, parameters: parameters, headers:headers, complete: complete)
    }

    
    class func getVerifiedAssets(_ complete: @escaping (_ assets: NSDictionary?, _ errorMessage: String?) -> Void) {
        getRequestWithUrl( "https://waves-wallet.firebaseio.com/" + "verified-assets.json", parameters: nil) { (info, error) in
            complete(info as? NSDictionary, error?.message)
        }
    }
   
    
    class func getBalancePair(priceAsset: String, amountAsset: String, complete: @escaping (_ info: NSDictionary?, _ errorMessage: String?) -> Void) {
        
        getRequestWithUrl(matcherURL + "matcher/orderbook/\(amountAsset)/\(priceAsset)/tradableBalance/\(WalletManager.getAddress())", parameters: nil) { (info, error) in
            complete(info as? NSDictionary, error?.message)
        }        
    }

    class func deleteOrder(amountAsset: String, priceAsset: String, request: CancelOrderRequest, complete: @escaping (_ errorMessage: String?) -> Void) {
        
        postRequestWithUrl(matcherURL + "matcher/orderbook/\(amountAsset)/\(priceAsset)/delete?" + String(Date().millisecondsSince1970), parameters: request.toJSON()) { (info, error) in
            complete(error?.message)
        }
    }

}
