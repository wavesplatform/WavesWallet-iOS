//
//  DexSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum Constants {
    static let stepSize: Float = 0.000000001
}

final class DexSortInteractor: DexSortInteractorProtocol {
    
    private let reposity = DexRepository()
    private let auth = FactoryInteractors.instance.authorization
    private let disposeBag = DisposeBag()
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DexSort.DTO.DexSortModel]> in
            
            guard let owner = self else { return Observable.empty() }
            return owner.reposity.list(by: wallet.wallet.address).flatMap({ (pairs) -> Observable<[DexSort.DTO.DexSortModel]> in
                
                var sortModels: [DexSort.DTO.DexSortModel] = []
                for pair in pairs {
                    let name = pair.amountAsset.name + " / " + pair.priceAsset.name
                    sortModels.append(.init(id: pair.id, name: name, sortLevel: pair.sortLevel))
                }
                return Observable.just(sortModels)
            })
            
        })
    }
   
    
    func move(model: DexSort.DTO.DexSortModel, overModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func move(model: DexSort.DTO.DexSortModel, underModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func delete(model: DexSort.DTO.DexSortModel) {
        
        auth.authorizedWallet().subscribe(onNext: { [weak self] (wallet) in
            
            guard let owner = self else { return }
            owner.reposity.delete(by: model.id, accountAddress: wallet.wallet.address)
            .subscribe()
            .disposed(by: owner.disposeBag)
            
        }).disposed(by: disposeBag)
    }
    
}
