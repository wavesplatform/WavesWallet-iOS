//
//  AliasRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import RxSwift

enum AliasesRepositoryError: Error {
    case invalid
    case dontExist
}

protocol AliasesRepositoryProtocol {
    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]>
    func alias(by name: String, accountAddress: String) -> Observable<String>
    func saveAliases(by accountAddress: String, aliases: [DomainLayer.DTO.Alias]) -> Observable<Bool>
}
