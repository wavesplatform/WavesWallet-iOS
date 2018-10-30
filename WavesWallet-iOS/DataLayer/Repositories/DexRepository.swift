//
//  DexRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexRepository: DexRepositoryProtocol {

    func save(pair: DexMarket.DTO.Pair, accountAddress: String) -> Observable<Bool> {
       
        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            try! realm.write {
                
                let lastSortLevel = realm.objects(DexAssetPair.self).sorted(byKeyPath: "sortLevel").last?.sortLevel ?? 0

                realm.add(DexAssetPair(id: pair.id,
                                       amountAsset: pair.amountAsset,
                                       priceAsset: pair.priceAsset,
                                       isGeneral: pair.isGeneral,
                                       sortLevel: lastSortLevel + 1), update: true)
            }
            observer.onNext(true)
            observer.onCompleted()
            
            return Disposables.create()
        })
        
    }
    
    func delete(by id: String, accountAddress: String) -> Observable<Bool> {

        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            
            guard let pair = realm.object(ofType: DexAssetPair.self,
                                          forPrimaryKey: id) else {
                                            observer.onNext(true)
                                            observer.onCompleted()
                                            return Disposables.create()
            }
            
            try! realm.write {
                realm.delete(pair)
            }
            
            observer.onNext(true)
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
    
    func list(by accountAddress: String) -> Observable<[DexAssetPair]> {

        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            let list = realm.objects(DexAssetPair.self).toArray()
            observer.onNext(list)
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
    
    func listListener(by accountAddress: String) -> Observable<[DexAssetPair]> {
      
        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            let result = realm.objects(DexAssetPair.self)
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .bind(to: observer)
            
            return Disposables.create([collection])
        })
    }
}
