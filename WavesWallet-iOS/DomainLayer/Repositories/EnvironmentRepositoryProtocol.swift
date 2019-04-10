//
//  EnvironmentsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension
import WavesSDKCrypto

enum EnvironmentRepositoryError: Error {
    case invalidURL
    case invalidResponse
}

protocol EnvironmentRepositoryProtocol {
    func accountEnvironment(accountAddress: String) -> Observable<Environment>
    func deffaultEnvironment(accountAddress: String) -> Observable<Environment>
    func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool>
}
