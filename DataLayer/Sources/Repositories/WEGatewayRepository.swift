//
//  WEGatewayRepositoryProtocol.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto
import RxSwift
import Moya
import DomainLayer

private enum Constants {
    static let sessionLifeTime: Int64 = 1200000
    static let grantType: String = "password"
    static let scope: String = "client"
}

private struct TransferBindingResponse: Codable {
    let addresses: [String]
    let amount_min: String
    let amount_max: String
    let tax_rate: Double
    let tax_flat: String
}

final class WEGatewayRepository: WEGatewayRepositoryProtocol {
    
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol
    
    private let weGateway: MoyaProvider<WEGateway.Service> = .anyMoyaProvider()
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.developmentConfigsRepository = developmentConfigsRepository
    }
    
    func transferBinding(request: DomainLayer.Query.WEGateway.TransferBinding) -> Observable<DomainLayer.DTO.WEGateway.TransferBinding> {
                        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              developmentConfigsRepository.developmentConfigs())
            .flatMap({ [weak self] (servicesEnvironment, developmentConfigs) ->  Observable<DomainLayer.DTO.WEGateway.TransferBinding> in
                guard let self = self else { return Observable.empty() }
                        
                let url = servicesEnvironment.walletEnvironment.servers.gateways.v2
                let exchangeClientSecret = developmentConfigs.exchangeClientSecret
                
                let transferBinding: WEGateway.Query.TransferBinding = .init(token: exchangeClientSecret,
                                                                             senderAsset: request.senderAsset,
                                                                             recipientAsset: request.recipientAsset,
                                                                             recipientAddress: request.recipientAddress)
                    
                return self
                    .weGateway
                    .rx
                    .request(.transferBinding(baseURL: url,
                                              query: transferBinding),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(TransferBindingResponse.self)
                    .map { DomainLayer.DTO.WEGateway.TransferBinding(addresses: $0.addresses,
                                                                     amountMin: $0.amount_min.decodeInt64FromBase64(),
                                                                     amountMax: $0.amount_max.decodeInt64FromBase64(),
                                                                     taxRate: $0.tax_rate,
                                                                     taxFlat: $0.tax_flat.decodeInt64FromBase64()) }
                    .asObservable()
            })
    }
}
