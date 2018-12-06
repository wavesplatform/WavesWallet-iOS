//
//  DexSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

final class DexSortInteractor: DexSortInteractorProtocol {
    
    private let reposity = FactoryRepositories.instance.dexRepository
    private let auth = FactoryInteractors.instance.authorization
    private let disposeBag = DisposeBag()
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<[DexSort.DTO.DexSortModel]> in
            
                guard let owner = self else { return Observable.empty() }
                return owner
                    .reposity
                    .list(by: wallet.address)
                    .flatMap({ (pairs) -> Observable<[DexSort.DTO.DexSortModel]> in

                        var sortModels: [DexSort.DTO.DexSortModel] = []
                        for pair in pairs {
                            let name = pair.amountAsset.name + " / " + pair.priceAsset.name
                            sortModels.append(.init(id: pair.id, name: name, sortLevel: pair.sortLevel))
                        }
                        return Observable.just(sortModels)
                    })
            })
    }
   
    func update(_ models: [DexSort.DTO.DexSortModel]) {
        
        auth
            .authorizedWallet()
            .subscribe(onNext: { (wallet) in
            
                let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address)

                try? realm?.write {
                    for model in models {
                        if let object = realm?.object(ofType: DexAssetPair.self, forPrimaryKey: model.id) {
                            object.sortLevel = model.sortLevel
                        }
                    }
                }
            
            })
            .disposed(by: disposeBag)
    }
    
   
    func delete(model: DexSort.DTO.DexSortModel) {
        
        auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Bool> in
                guard let owner = self else { return Observable.never() }

                return owner
                    .reposity
                    .delete(by: model.id,
                            accountAddress: wallet.address)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
 
}
