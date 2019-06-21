//
//  AddressUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

public protocol AddressUseCaseProtocol {
    func address(by ids: [String], myAddress: String) -> Observable<[DomainLayer.DTO.Address]>
    func addressSync(by ids: [String], myAddress: String) -> SyncObservable<[DomainLayer.DTO.Address]>
}
    

