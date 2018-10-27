//
//  AliasRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import RxSwift

enum AliasesRepositoryProtocolError: Error {
    case invalid
}

protocol AliasesRepositoryProtocol {
    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]>
}
