//
//  SendFeeInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let minWavesSponsoredBalance: Decimal = 1.005
}

final class SendFeeInteractor: SendFeeInteractorProtocol {
    
    private let balance = FactoryInteractors.instance.accountBalance
    private let auth = FactoryInteractors.instance.authorization
    private let transactions = FactoryInteractors.instance.transactions
    
    func assets() -> Observable<[DomainLayer.DTO.Asset]> {
        return balance.balances().map({ (smartAssets) -> [DomainLayer.DTO.Asset] in
            return smartAssets.filter {
                let balance = Money($0.sponsorBalance, GlobalConstants.WavesDecimals)
                return $0.asset.isWaves || ($0.asset.isSponsored && balance.decimalValue >= Constants.minWavesSponsoredBalance)
            }.map{ $0.asset }
        })
    }
    
    func calculateFee(assetID: String) -> Observable<Money> {
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Money> in
            guard let owner = self else { return Observable.empty() }
            return owner.transactions.calculateFee(by: .sendTransaction(assetID: assetID), accountAddress: wallet.address)
        })
    }
}
