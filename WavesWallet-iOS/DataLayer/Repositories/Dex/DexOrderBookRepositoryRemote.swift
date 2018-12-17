//
//  DexOrderBookRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexOrderBookRepositoryRemote: DexOrderBookRepositoryProtocol {

    func orderBook(amountAsset: String, priceAsset: String) -> Observable<API.DTO.OrderBook> {

        return Observable.create({ (subscribe) -> Disposable in
          
            let url = GlobalConstants.Matcher.orderBook(amountAsset, priceAsset)

            NetworkManager.getRequestWithUrl(url, parameters: nil, complete: { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let data = info?.data {
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        let orderBookModel = try decoder.decode(API.DTO.OrderBook.self, from: data)
                        subscribe.onNext(orderBookModel)
                        subscribe.onCompleted()
                    }
                    catch let error {
                        subscribe.onError(error)
                    }
                }
            })
            
            return Disposables.create()
        })
    }
}
