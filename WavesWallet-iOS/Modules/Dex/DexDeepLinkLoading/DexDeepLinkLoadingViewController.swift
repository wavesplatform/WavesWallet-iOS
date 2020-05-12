//
//  DexDeepLinkLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 31.10.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer
import RxSwift

private enum Constants {
    static let amountAssetKey = "assetId1"
    static let priceAssetKey = "assetId2"
}

final class DexDeepLinkLoadingViewController: UIViewController {

    private let assets = UseCasesFactory.instance.assets
    private let auth = UseCasesFactory.instance.authorization
    
    var deepLink: DeepLink!
    var didComplete:((DexTraderContainer.DTO.Pair) -> Void)?
    var didFail:(() -> Void)?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAssets()
        
    }
    
    private func loadAssets() {
        if let amountAssetId = deepLink.amountAsset, let priceAssetId = deepLink.priceAsset {
            auth.authorizedWallet().flatMap { [weak self] (wallet) -> Observable<[Asset]> in
                guard let self = self else { return Observable.empty() }
                return self.assets.assets(by: [amountAssetId, priceAssetId], accountAddress: wallet.address)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (assets) in
                guard let self = self else { return }
                if let amountAsset = assets.first(where: {$0.id == amountAssetId}),
                    let priceAsset = assets.first(where: {$0.id == priceAssetId}) {
                    
                    let isGeneral = amountAsset.isGeneral && priceAsset.isGeneral
                    let pair = DexTraderContainer.DTO.Pair(amountAsset: amountAsset.dexAsset,
                                                           priceAsset: priceAsset.dexAsset,
                                                           isGeneral: isGeneral)
                    self.didComplete?(pair)
                }
                else {
                    self.didFail?()
                }
                
            }).disposed(by: disposeBag)
        }
        else {
            didFail?()
        }
    }
}


private extension DeepLink {
    
    var amountAsset: String? {
        return url.params.first(where: {$0.key == Constants.amountAssetKey})?.value
    }
    
    var priceAsset: String? {
        return url.params.first(where: {$0.key == Constants.priceAssetKey})?.value
    }
    
}

private extension URL {
    
    var params: [String: String] {
        
        guard let query = self.query else { return [:] }
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {

            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
}
