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
   
    @discardableResult fileprivate class func baseRequestWithUrl(_ url: String, method: HTTPMethod, parameters: Dictionary <String, Any>?, headers: HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping ( _ completeInfo: JSON?, _ error: NetworkError?) -> Void) -> DataRequest {
        
        return Alamofire.request(url, method: method, parameters : parameters, encoding: encoding, headers: headers)
            
            .responseJSON { response in
                
                if response.error != nil {
                    
                    let error = response.error as NSError?
                    
                    if let error = error, error.code != NSURLErrorCancelled {
                        complete(nil, NetworkError.error(by: error))
                    }
                }
                else if response.response?.statusCode != 200 {
                    
                    if let data = response.data {
                        complete(nil, NetworkError.error(data: data))
                    }
                    else {
                        complete(nil, NetworkError.serverError)
                    }
                }
                else {
                    
                    if let dict = response.result.value as? NSDictionary {
                        
                        if dict["status"] as? String == "error" {
                            
                            if let data = response.data {
                                complete(nil, NetworkError.error(data: data))
                            }
                            else {
                                complete(nil, NetworkError.serverError)
                            }
                        }
                        else if dict["error"] as? String != nil {
                            
                            if let data = response.data {
                                complete(nil, NetworkError.error(data: data))
                            }
                            else {
                                complete(nil, NetworkError.serverError)
                            }
                        }
                        else if let value = parsedObjectFromResponse(response.result.value) {
                            complete (JSON(value), nil)
                        }
                        else {
                            complete(nil, NetworkError.serverError)
                        }
                    }
                    else if let value = parsedObjectFromResponse(response.result.value) {
                        complete(JSON(value), nil)
                    }
                    else {
                        complete(nil, NetworkError.serverError)
                    }
                }
        }

    }

    @discardableResult class func postRequestWithUrl(_ url: String, parameters: Dictionary <String, Any>?, complete: @escaping ( _ completeInfo: JSON?, _ error: NetworkError?) -> Void) -> DataRequest {
    
        return baseRequestWithUrl(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, complete: complete)
    }
    
    @discardableResult class func getRequestWithUrl(_ url: String, parameters: Dictionary <String, Any>?, headers: HTTPHeaders? = nil,  complete: @escaping ( _ completeInfo: JSON?, _ error: NetworkError?) -> Void) -> DataRequest {

        return baseRequestWithUrl(url, method: .get, parameters: parameters, headers:headers, complete: complete)
    }

}
