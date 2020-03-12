//
//  WEGatewayUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

final class WEGatewayUseCase: WEGatewayUseCaseProtocol {
    
    private let gatewayRepository: WEGatewayRepositoryProtocol
    private let oAuthRepository: WEOAuthRepositoryProtocol
    private let authorizationUseCase: AuthorizationUseCaseProtocol
    
    init(gatewayRepository: WEGatewayRepositoryProtocol,
         oAuthRepository: WEOAuthRepositoryProtocol,
         authorizationUseCase: AuthorizationUseCaseProtocol) {
        self.gatewayRepository = gatewayRepository
        self.oAuthRepository = oAuthRepository
        self.authorizationUseCase = authorizationUseCase
    }
    
    func receiveBinding(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding> {
        
        return authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] signedWallet -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding> in
                
                guard let self = self else { return Observable.never() }
                
                return self.oAuthRepository
                        .oauthToken(signedWallet: signedWallet)
                      .flatMap { (token) -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding> in
                          
                          
                          return Observable.just(DomainLayer.DTO.WEGateway.SmartTransferBinding.init(addresses: ["ZALYPA", "GORIZ", "ALEX"],
                                                                                                           amountMin: Money(10, 1), amountMax: Money(1000, 1), fee: Money(10, 1)))
                      }
            }
    }
    
    func sendBinding(asset: DomainLayer.DTO.Asset, address: String) -> Observable<DomainLayer.DTO.WEGateway.SmartTransferBinding> {
        return Observable.never()
    }
}

