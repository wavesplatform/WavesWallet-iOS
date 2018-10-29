//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

final class DexListInteractor: DexListInteractorProtocol {
   
    private let repository = DexRepository()
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private let disposeBag = DisposeBag()
    
    private var request: DataRequest?
    
    func pairs() -> Observable<[DexList.DTO.Pair]> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let owner = self else { return Disposables.create() }
            owner.authorizationInteractor.authorizedWallet().subscribe(onNext: { [weak self] (wallet) in
                
                guard let owner = self else { return }
                
                Observable.merge([owner.repository.list(by: wallet.wallet.address),
                                  owner.repository.listListener(by: wallet.wallet.address)]).subscribe(onNext: { [weak self] (pairs) in
                                    
                        guard let owner = self else { return }
                        owner.getListPairs(by: pairs, complete: { (pairs, error) in
                            subscribe.onNext(pairs)
                        })
                                  
                }).disposed(by: owner.disposeBag)
                
            }).disposed(by: owner.disposeBag)
            
            return Disposables.create {
                self?.request?.cancel()
            }
        })
    }
    
    func refreshPairs() {
        
    }
}

private extension DexListInteractor {
    
    func getListPairs(by pairs: [DexAssetPair], complete:@escaping(_ pairs: [DexList.DTO.Pair], _ error: ResponseTypeError?) -> Void) {
        
        var url = Environments.current.servers.dataUrl.relativeString + "/v0" + "/pairs"
        
        for pair in pairs {
            if (url as NSString).range(of: "?").location == NSNotFound {
                url.append("?")
            }
            if url.last != "?" {
                url.append("&")
            }
            url.append("pairs=" + pair.amountAsset.id + "/" + pair.priceAsset.id)
        }
        
        request = NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
            
            if let info = info {

                var listPairs: [DexList.DTO.Pair] = []

                for (index, item) in info["data"].arrayValue.enumerated() {
                    
                    let localPair = pairs[index]
                    
                    let amountAsset = Dex.DTO.Asset(id: localPair.amountAsset.id,
                                                    name: localPair.amountAsset.name,
                                                    decimals: localPair.amountAsset.decimals)
                    
                    let priceAsset = Dex.DTO.Asset(id: localPair.priceAsset.id,
                                                   name: localPair.priceAsset.name,
                                                   decimals: localPair.priceAsset.decimals)
                
                    let firstPrice = Money(value: Decimal(item["firstPrice"].doubleValue), amountAsset.decimals)
                    let lastPrice = Money(value: Decimal(item["lastPrice"].doubleValue), amountAsset.decimals)
                    
                    let pair = DexList.DTO.Pair(firstPrice: firstPrice,
                                                lastPrice: lastPrice,
                                                amountAsset: amountAsset,
                                                priceAsset: priceAsset,
                                                isHidden: false,
                                                isFiat: false)
                    listPairs.append(pair)
                }
                complete(listPairs, nil)
            }
            else {
                complete([], error)
            }
            
        }
    }
}
