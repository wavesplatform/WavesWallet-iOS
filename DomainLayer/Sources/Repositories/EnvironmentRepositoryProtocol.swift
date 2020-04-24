//
//  EnvironmentsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import Extensions

public enum EnvironmentRepositoryError: Error {
    case invalidURL
    case invalidResponse
}

public protocol EnvironmentRepositoryProtocol {
            
    func walletEnvironment() -> Observable<WalletEnvironment>    
    
    var environmentKind: WalletEnvironment.Kind { get set }
}
