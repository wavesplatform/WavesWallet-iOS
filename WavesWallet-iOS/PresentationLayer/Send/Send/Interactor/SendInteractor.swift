//
//  SendInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


private enum Constasts {
    static let apiPath = "api/v1/"
    static let apiRate = "get_xrate.php"
    static let aliasApi = "/v0/aliases/"
}

final class SendInteractor: SendInteractorProtocol {
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance> {
        
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances(isNeedUpdate: false)
            .flatMap({ balances -> Observable<DomainLayer.DTO.AssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset?.wavesId == Environments.Constants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
            })
    }
    
    func gateWayInfo(asset: DomainLayer.DTO.AssetBalance) -> Observable<Response<Send.DTO.GatewayInfo>> {
        return Observable.create({ (subscribe) -> Disposable in
        
            guard let asset = asset.asset else { return Disposables.create() }
        
            let params = ["f" : asset.wavesId ?? "",
                          "t" : asset.gatewayId ?? ""]
            
            let url = GlobalConstants.coinomatUrl + Constasts.apiPath + Constasts.apiRate
            NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                
                if let info = info {
                    let json = JSON(info)
                    
                    let min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
                    let max = Money(value: Decimal(json["in_max"].doubleValue), asset.precision)
                    let fee = Money(value: Decimal(json["fee_in"].doubleValue + json["fee_out"].doubleValue), asset.precision)

                    let shortName = asset.gatewayId ?? json["to_txt"].stringValue
                    
                    let info = Send.DTO.GatewayInfo(assetName: asset.displayName, assetShortName: shortName, minAmount: min, maxAmount: max, fee: fee)
                    subscribe.onNext(.init(output: info, error: nil))
                }
                else {
                    subscribe.onNext(.init(output: nil, error: errorMessage))
                }
            })
            return Disposables.create()
        })
    }
    
    func validateAlis(alias: String) -> Observable<Bool> {
        
        return Observable.create({ (subscribe) -> Disposable in
        
            let url = Environments.Mainnet.servers.dataUrl.relativeString + Constasts.aliasApi + alias

            let req = NetworkManager.getRequestWithPath(path: "", parameters: nil, customUrl: url, complete: { (info, errorMessage) in
                subscribe.onNext(errorMessage == nil)
            })
            
            return Disposables.create {
                req.cancel()
            }
        })
    }
}
