//
//  DexRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

//TODO: Rename to Local
final class DexRepository: DexRepositoryProtocol {

    func save(pair: DexMarket.DTO.Pair, accountAddress: String) -> Observable<Bool> {
       
        return Observable.create({ (subscribe) -> Disposable in
            
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            try! realm.write {
                
                let lastSortLevel = realm.objects(DexAssetPair.self).sorted(byKeyPath: "sortLevel").last?.sortLevel ?? 0
                
                realm.add(DexAssetPair(id: pair.id,
                                       amountAsset: pair.amountAsset,
                                       priceAsset: pair.priceAsset,
                                       isGeneral: pair.isGeneral,
                                       sortLevel: lastSortLevel + 1), update: true)
            }
            
            subscribe.onNext(true)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func delete(by id: String, accountAddress: String) -> Observable<Bool> {

        return Observable.create({ (subscribe) -> Disposable in
            
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            if let pair = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)  {
                try! realm.write {
                    realm.delete(pair)
                }
            }
            
            subscribe.onNext(true)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func list(by accountAddress: String) -> Observable<[DexMarket.DTO.Pair]> {
        
        return Observable.create({ (subscribe) -> Disposable in

            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            let objects = realm.objects(DexAssetPair.self).sorted(by: {$0.sortLevel < $1.sortLevel}).map { return DexMarket.DTO.Pair($0, isChecked: true)}

            subscribe.onNext(objects)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func listListener(by accountAddress: String) -> Observable<[DexMarket.DTO.Pair]> {

        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
        
            let result = realm.objects(DexAssetPair.self)
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .map({ list -> [DexMarket.DTO.Pair] in
                    return list.sorted(by: {$0.sortLevel < $1.sortLevel}) .map { return DexMarket.DTO.Pair($0, isChecked: true) }})
                .bind(to: observer)

            return Disposables.create([collection])
        })
    }
}
