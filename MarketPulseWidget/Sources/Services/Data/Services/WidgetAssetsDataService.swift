//
//  WidgetAssetsDataService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import Moya
import WavesSDKExtensions

protocol WidgetAssetsDataServiceProtocol {
    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]>
}

final class WidgetAssetsDataService: WidgetAssetsDataServiceProtocol {
   
    private let assetsProvider: MoyaProvider<WidgetDataService.Target.Assets> = InternalWidgetService.moyaProvider()

    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]> {
        
        return self
            .assetsProvider
            .rx
            .request(.init(kind: .getAssets(ids: ids),
                           dataUrl: InternalWidgetService.shared.dataUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Single<Response> in
                return Single<Response>.error(NetworkError.error(by: error))
            })
            .map(WidgetDataService.Response<[WidgetDataService.Response<DataService.DTO.Asset>]>.self,
                 atKeyPath: nil,
                 using: JSONDecoder.isoDecoderBySyncingTimestamp(0),
                 failsOnEmptyData: false)
            .map { $0.data.map { $0.data } }
            .asObservable()
    }
}
