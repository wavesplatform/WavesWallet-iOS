//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

//TODO: Rename to Services
final class AddressRepositoryRemote: AddressRepositoryProtocol {
    
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func isSmartAddress(serverEnvironment: ServerEnvironment,
                        accountAddress: String) -> Observable<Bool> {
        
        return wavesSDKServices.wavesServices(environment: serverEnvironment)
            .nodeServices
            .addressesNodeService
            .scriptInfo(address: accountAddress)
            .map { ($0.extraFee ?? 0) > 0 }
    }
}
