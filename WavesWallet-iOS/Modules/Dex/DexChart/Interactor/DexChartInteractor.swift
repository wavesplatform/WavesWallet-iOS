//
//  DexChartInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift

private enum Constants {
    static let timeStart = "timeStart"
    static let timeEnd = "timeEnd"
    static let interval = "interval"
}

final class DexChartInteractor: DexChartInteractorProtocol {
    private let candlesReposotiry = UseCasesFactory.instance.repositories.candlesRepository
    private let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

    // TODO: Move to method
    var pair: DexTraderContainer.DTO.Pair!

    func candles(timeFrame: DomainLayer.DTO.Candle.TimeFrameType,
                 timeStart: Date,
                 timeEnd: Date) -> Observable<[DomainLayer.DTO.Candle]> {
        return serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Candle]> in

                guard let self = self else { return Observable.never() }

                return self.candlesReposotiry.candles(serverEnvironment: serverEnvironment,
                                                      amountAsset: self.pair.amountAsset.id,
                                                      priceAsset: self.pair.priceAsset.id,
                                                      timeStart: timeStart,
                                                      timeEnd: timeEnd,
                                                      timeFrame: timeFrame)
                    .catchError { (_) -> Observable<[DomainLayer.DTO.Candle]> in
                        Observable.just([])
                    }
            }
    }
}
