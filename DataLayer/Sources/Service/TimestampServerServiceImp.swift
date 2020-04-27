//
//  TimestampServerDiffServiceImp.swift
//  DataLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

private enum Constants {
    static let minServerTimestampDiff: Int64 = 1000 * 30
}

final class TimestampServerServiceImp: TimestampServerService {
    
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func timestampServerDiff(serverEnvironment: ServerEnvironment) -> Observable<Int64> {
        wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .nodeServices
            .utilsNodeService
            .time()
            .flatMap { time -> Observable<Int64> in
                let localTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
                let diff = localTimestamp - time.NTP
                let timestamp = abs(diff) > Constants.minServerTimestampDiff ? diff : 0
                
                return Observable.just(timestamp)
        }
    }
}
