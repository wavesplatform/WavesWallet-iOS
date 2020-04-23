//
//  ReceiveCryptocurrencyInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

private enum Constants {
    static let btcSegWitAddress = NSPredicate(format: "SELF MATCHES %@",
                                              "((bc|tb)(0([ac-hj-np-z02-9]{39}|[ac-hj-np-z02-9]{59})|1[ac-hj-np-z02-9]{8,87}))")
    static let btcLegacyAddress = NSPredicate(format: "SELF MATCHES %@", "([13]|[mn2])[a-km-zA-HJ-NP-Z1-9]{25,39}")
}

final class ReceiveCryptocurrencyInteractor: ReceiveCryptocurrencyInteractorProtocol {
    private let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let coinomatRepository = UseCasesFactory.instance.repositories.coinomatRepository
    private let gatewayRepository = UseCasesFactory.instance.repositories.gatewayRepository
    private let weGatewayUseCase = UseCasesFactory.instance.weGatewayUseCase
    private let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        let serverEnvironment = serverEnvironmentUseCase.serverEnviroment()
        let wallet = auth.authorizedWallet()
        
        return Observable.zip(wallet, serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in

                guard let self = self, let gatewayType = asset.gatewayType else { return Observable.empty() }

                switch gatewayType {
                case .gateway:
                    return self.gatewayRepository.startDepositProcess(serverEnvironment: serverEnvironment,
                                                                      address: wallet.address,
                                                                      asset: asset)
                        .map { startDeposit -> ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo> in

                            let addresses = [startDeposit.address.displayInfoAddress()]

                            let displayInfo = ReceiveCryptocurrency.DTO.DisplayInfo(addresses: addresses,
                                                                                    asset: asset,
                                                                                    minAmount: startDeposit.minAmount)

                            return ResponseType(output: displayInfo, error: nil)
                        }

                case .coinomat:
                    guard let currencyFrom = asset.gatewayId,
                        let currencyTo = asset.wavesId else { return Observable.empty() }

                    let tunnel = self.coinomatRepository.tunnelInfo(asset: asset,
                                                                    currencyFrom: currencyFrom,
                                                                    currencyTo: currencyTo,
                                                                    walletTo: wallet.address)

                    let rate = self.coinomatRepository.getRate(asset: asset)
                    return Observable.zip(tunnel, rate)
                        .flatMap { tunnel, _ -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in

                            let displayInfo = ReceiveCryptocurrency.DTO
                                .DisplayInfo(addresses: [tunnel.address.displayInfoAddress()],
                                             asset: asset,
                                             minAmount: tunnel.min)
                            return Observable.just(ResponseType(output: displayInfo, error: nil))
                        }
                case .exchange:
                    return self.weGatewayUseCase
                        .receiveBinding(asset: asset)
                        .map { model -> ReceiveCryptocurrency.DTO.DisplayInfo in
                            ReceiveCryptocurrency.DTO.DisplayInfo(addresses: model.addresses.displayInfoAddresses(),
                                                                  asset: asset,
                                                                  minAmount: model.amountMin)
                        }
                        .map { ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>(output: $0, error: nil) }
                        .catchError {
                            Observable.just(ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>(output: nil,
                                                                                                error: NetworkError
                                                                                                    .error(by: $0)))
                        }
                }
            }
            .catchError { error -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>> in
                if let networkError = error as? NetworkError {
                    return Observable.just(ResponseType(output: nil, error: networkError))
                }

                return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
            }
    }
}

private extension Array where Element == ReceiveCryptocurrency.DTO.DisplayInfo.Address {
    func addressesSort(asset _: DomainLayer.DTO.Asset) -> [Element] {
        return self
    }
}

private extension Array where Element == String {
    func displayInfoAddresses() -> [ReceiveCryptocurrency.DTO.DisplayInfo.Address] {
        return enumerated()
            .map { index, element -> ReceiveCryptocurrency.DTO.DisplayInfo.Address in
                element
                    .displayInfoAddress(deffaultName: Localizable.Waves.Receivecryptocurrency.Address.Default
                        .name("\(index + 1)"))
            }
    }
}

private extension String {
    func displayInfoAddress(deffaultName: String = "Address") -> ReceiveCryptocurrency.DTO.DisplayInfo.Address {
        let new = Constants.btcSegWitAddress
        let old = Constants.btcLegacyAddress

        var name: String = deffaultName
        if new.evaluate(with: self) {
            name = "SegWit Address"
        } else if old.evaluate(with: self) {
            name = "Legacy Address"
        }

        return ReceiveCryptocurrency.DTO.DisplayInfo.Address(name: name,
                                                             address: self)
    }
}
