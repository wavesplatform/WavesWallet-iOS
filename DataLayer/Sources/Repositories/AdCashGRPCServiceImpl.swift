//
//  AdCashService.swift
//  DataLayer
//
//  Created by vvisotskiy on 20.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
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
                        case let .success(data):
                            let assets = data.acashAssets.map { ACashAsset(from: $0) }
                            completion(.success(assets))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
            },
                       onError: { error in completion(.failure(error)) })
            .disposed(by: disposeBag)
    }

    public func getACashAssetsExchangeRate(signedWallet: SignedWallet,
                                           paymentSystem: PaymentSystem,
                                           senderAsset: String,
                                           recipientAsset: String,
                                           senderAssetAmount: Double,
                                           completion: @escaping (Result<Double, Error>) -> Void) {
        obtainWEOAuthToken(signedWallet: signedWallet)
            .subscribe(onNext: { token, addressGprc in
                var request = Acash_GetACashAssetsExchangeRateRequest()
                request.senderAsset = senderAsset
                request.recipientAsset = recipientAsset
                request.senderAssetAmount = senderAssetAmount
                request.paymentSystem = paymentSystem.grpcPaymentSystem

                let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

                let client: Acash_ACashDepositsClient = grpcClient(address: addressGprc, eventLoopGroup: group, oAToken: token)

                client.getACashAssetsExchangeRate(request)
                    .response
                    .whenComplete { result in
                        switch result {
                        case let .success(data): completion(.success(data.rate))
                        case let .failure(error): completion(.failure(error))
                        }
                    }
            },
                       onError: { error in completion(.failure(error)) })
            .disposed(by: disposeBag)
    }

    public func deposite(signedWallet: SignedWallet,
                         paymentSystem: PaymentSystem,
                         senderAsset: String,
                         recipientAsset: String,
                         exchangeAddress: String,
                         amount: Double,
                         completion: @escaping (Result<String, Error>) -> Void) {
        obtainWEOAuthToken(signedWallet: signedWallet)
            .subscribe(onNext: { token, address in
                var request = Acash_RegisterOrderRequest()
                request.address = exchangeAddress
                request.amount = amount
                request.senderAsset = senderAsset
                request.recipientAsset = recipientAsset

                request.paymentSystem = paymentSystem.grpcPaymentSystem
                
                let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

                let client: Acash_ACashDepositsClient = grpcClient(address: address, eventLoopGroup: group, oAToken: token)
                client.registerOrder(request)
                    .response
                    .whenComplete { result in
                        switch result {
                        case let .success(response): completion(.success(response.queryParameters))
                        case let .failure(error): completion(.failure(error))
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

        let assetId: String
        if aCashAsset.type == .crypto {
            assetId = aCashAsset.id.replacingOccurrences(of: "USD", with: DomainLayerConstants.acUSDId)
                .replacingOccurrences(of: "WAVES", with: "AC_WAVES")
                .replacingOccurrences(of: "WEST", with: "AC_WEST")
        } else {
            assetId = aCashAsset.id
        }

        self.init(id: assetId,
                  name: aCashAsset.name,
                  kind: kind,
                  decimals: aCashAsset.decimals)
    }
}

private extension PaymentSystem {
    var grpcPaymentSystem: Acash_PaymentSystem {
        switch self {
        case .acash:
            return .acash
        case .card:
            return .card
        }
    }
}
