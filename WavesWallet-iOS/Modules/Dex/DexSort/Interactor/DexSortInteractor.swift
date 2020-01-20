//
//  DexSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

final class DexSortInteractor: DexSortInteractorProtocol {
    
    private let reposity = UseCasesFactory.instance.repositories.dexRealmRepository
    private let auth = UseCasesFactory.instance.authorization
    private let disposeBag = DisposeBag()
    private let assetsUseCase = UseCasesFactory.instance.assets
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<[DexSort.DTO.DexSortModel]> in
            
                guard let self = self else { return Observable.empty() }
                return self
                    .reposity
                    .list(by: wallet.address)
                    .flatMap({ [weak self] (pairs) -> Observable<[DexSort.DTO.DexSortModel]> in
                        guard let self = self else { return Observable.empty() }
                        
                        return self.assetsUseCase.assets(by: pairs.assetsIds, accountAddress: wallet.address)
                            .map { (assets) -> [DexSort.DTO.DexSortModel] in
                                
                                var sortModels: [DexSort.DTO.DexSortModel] = []
                                for pair in pairs {
                                    guard let amountAsset = assets.first(where: {$0.id == pair.amountAssetId}) else { continue }
                                    guard let priceAsset = assets.first(where: {$0.id == pair.priceAssetId}) else { continue }
                                    
                                    let name = amountAsset.displayName + " / " + priceAsset.displayName
                                    sortModels.append(.init(id: pair.id, name: name, sortLevel: pair.sortLevel))
                                }
        
                                return sortModels
                        }
                    })
            })
    }
   
    func update(_ models: [DexSort.DTO.DexSortModel]) {
        
        auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                let ids = models.reduce(into:  [String : Int](), { $0[$1.id] = $1.sortLevel})
                return self.reposity.updateSortLevel(ids: ids, accountAddress: wallet.address)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
   
    func delete(model: DexSort.DTO.DexSortModel) {
        
        auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }

                return self
                    .reposity
                    .delete(by: model.id,
                            accountAddress: wallet.address)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
 
}
