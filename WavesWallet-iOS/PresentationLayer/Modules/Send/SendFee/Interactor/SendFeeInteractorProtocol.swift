//
//  SendFeeInteractorProcotol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol SendFeeInteractorProtocol {
    func assets() -> Observable<[DomainLayer.DTO.Asset]>
    func calculateFee(assetID: String) -> Observable<Money>
}
