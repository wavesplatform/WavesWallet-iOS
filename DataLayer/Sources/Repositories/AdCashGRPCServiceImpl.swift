//
//  AdCashService.swift
//  DataLayer
//
//  Created by vvisotskiy on 20.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import GRPC
import RxSwift

public enum AdCashGRPCServiceError: Error {
    case getACashAssetsJsonFailureParsing
}

// TODO: сделать DAO для токена
public final class AdCashGRPCServiceImpl: AdCashGRPCService {
    
    /// Получение токена
    private let weOAuthRepository: WEOAuthRepositoryProtocol
    
    /// Некоторые вспомогательные данные для получения токена
    private let serverEnvironmentRepository: ServerEnvironmentRepository
    
    private let disposeBag = DisposeBag()
    
    public init(weOAuthRepository: WEOAuthRepositoryProtocol, serverEnvironmentRepository: ServerEnvironmentRepository) {
        self.weOAuthRepository = weOAuthRepository
        self.serverEnvironmentRepository = serverEnvironmentRepository
    }

    public func getACashAssets(signedWallet: SignedWallet, completion: @escaping (Result<[ACashAsset], Error>) -> Void) {
        obtainWEOAuthToken(signedWallet: signedWallet)
            .subscribe(onNext: { token, addressGrpc in
                let request = Acash_GetACashAssetsRequest()
                
                let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
                
                let client: Acash_ACashDepositsClient = grpcClient(address: addressGrpc, eventLoopGroup: group, oAToken: token)
                
                client.getACashAssets(request)
                    .response
                    .whenComplete { result in
                        switch result {
                        case .success(let data):
                            let assets = data.acashAssets.map { ACashAsset(from: $0) }
                            completion(.success(assets))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                }
             },
                       onError: { error in completion(.failure(error)) })
            .disposed(by: disposeBag)
    }
    
    public func getACashAssetsExchangeRate(signedWallet: SignedWallet,
                                           senderAsset: String,
                                           recipientAsset: String,
                                           senderAssetAmount: Double,
                                           completion: @escaping (Result<Void, Error>) -> Void) {
        obtainWEOAuthToken(signedWallet: signedWallet)
            .subscribe(onNext: { token, addressGprc in
                var request = Acash_GetACashAssetsExchangeRateRequest()
                request.senderAsset = senderAsset
                request.recipientAsset = recipientAsset
                request.senderAssetAmount = senderAssetAmount
                
                let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
                
                let client: Acash_ACashDepositsClient = grpcClient(address: addressGprc, eventLoopGroup: group, oAToken: token)
                
                client.getACashAssetsExchangeRate(request)
                    .response
                    .whenComplete { result in
                        switch result {
                        case .success(let data):
                            break
                        case .failure(let error):
                            break
                        }
                }
            },
                       onError: { error in completion(.failure(error)) })
            .disposed(by: disposeBag)
    }
    
    private func obtainWEOAuthToken(signedWallet: SignedWallet) -> Observable<(token: String, addressGrpc: String)> {
        serverEnvironmentRepository.serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<(token: String, addressGrpc: String)> in
                guard let strongSelf = self else { return Observable.never() }
                return strongSelf.weOAuthRepository.oauthToken(signedWallet: signedWallet)
                    .map { ($0.accessToken, serverEnvironment.servers.wavesExchangeGrpcAddress) }
                    .catchError { Observable.error($0) }
        }
        .catchError { Observable.error($0) }
    }
}

private extension ACashAsset {
    init(from aCashAsset: Acash_ACashAsset) {
        let kind: ACashAsset.Kind
        switch aCashAsset.type {
        case .crypto: kind = .crypto
        case .fiat: kind = .fiat
        case .UNRECOGNIZED: kind = .unrecognized
        }
        
        self.init(id: aCashAsset.id,
                  name: aCashAsset.name,
                  kind: kind,
                  decimals: aCashAsset.decimals)
    }
}
