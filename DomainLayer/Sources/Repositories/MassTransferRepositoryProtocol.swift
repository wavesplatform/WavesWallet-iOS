//
//  MassTransferRepositoryProtocol.swift
//  DomainLayer
//
//  Created by vvisotskiy on 10.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import WavesSDK
import Foundation
import RxSwift

public protocol MassTransferRepositoryProtocol: AnyObject {
    func obtainPayoutsHistory(query: DataService.Query.MassTransferDataQuery)
        -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>>
}
