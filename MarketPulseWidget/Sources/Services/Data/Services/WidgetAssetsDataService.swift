//
//  WidgetAssetsDataService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DataLayer
import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

protocol WidgetAssetsDataServiceProtocol {
    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]>
}

final class WidgetAssetsDataService: WidgetAssetsDataServiceProtocol {
    private let assetsProvider: MoyaProvider<WidgetDataService.Target.Assets> = InternalWidgetService.moyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] environment -> Observable<[DataService.DTO.Asset]> in

                guard let self = self else { return Observable.never() }
                return self.assetsProvider
                    .rx
                    .request(.init(kind: .getAssets(ids: ids),
                                   dataUrl: environment.servers.dataUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { (error) -> Single<Response> in
                        Single<Response>.error(NetworkError.error(by: error))
                    }
                    .map(WidgetDataService.Response<[WidgetDataService.Response<DataService.DTO.Asset>]>.self,
                         atKeyPath: nil,
                         using: JSONDecoder.isoDecoderBySyncingTimestamp(0),
                         failsOnEmptyData: false)
                    .map { $0.data.map { $0.data } }
                    .asObservable()
            }
    }
}
