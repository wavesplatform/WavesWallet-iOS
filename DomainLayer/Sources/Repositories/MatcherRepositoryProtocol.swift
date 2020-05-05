//
//  MatcherRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import Extensions

public protocol MatcherRepositoryProtocol {
    
    func matcherPublicKey(serverEnvironment: ServerEnvironment) -> Observable<DomainLayer.DTO.PublicKey>

    func settingsIdsPairs(serverEnvironment: ServerEnvironment) -> Observable<[String]>
}
