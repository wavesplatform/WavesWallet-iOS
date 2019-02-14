//
//  DexRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexRealmRepositoryLocal: DexRealmRepositoryProtocol {

    
    func updateSortLevel(ids: [String: Int], accountAddress: String) -> Observable<Bool> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                try realm.write {
                    for id in ids {
                        if let object = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id.key) {
                            object.sortLevel = id.value
                        }
                    }
                }
                subscribe.onNext(true)
            }
            catch _ {
                subscribe.onNext(false)
            }
            
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    func checkmark(pairs: [DomainLayer.DTO.Dex.SmartPair], accountAddress: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        return Observable.create({ (subscribe) -> Disposable in
        
            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                var newPairs = pairs
                for (index, pair) in pairs.enumerated() {
                    newPairs[index] = pair.mutate {
                        $0.isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: pair.id) != nil
                    }
                }
                subscribe.onNext(newPairs)
            }
            catch let error {
                subscribe.onError(error)
            }

            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func save(pair: DomainLayer.DTO.Dex.SmartPair, accountAddress: String) -> Observable<Bool> {
       
        return Observable.create({ (subscribe) -> Disposable in
            
            //TODO: Error
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
            
            //TODO: Error
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
    
    func list(by accountAddress: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        return Observable.create({ (subscribe) -> Disposable in

            //TODO: Error
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            let objects = realm.objects(DexAssetPair.self).sorted(by: {$0.sortLevel < $1.sortLevel}).map { return DomainLayer.DTO.Dex.SmartPair($0, isChecked: true)}

            subscribe.onNext(objects)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func listListener(by accountAddress: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return Observable.create({ observer -> Disposable in
            
            //TODO: Error
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
        
            let result = realm.objects(DexAssetPair.self)
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .map({ list -> [DomainLayer.DTO.Dex.SmartPair] in
                    return list.sorted(by: {$0.sortLevel < $1.sortLevel}) .map { return DomainLayer.DTO.Dex.SmartPair($0, isChecked: true) }})
                .bind(to: observer)

            return Disposables.create([collection])
        })         
    }
}
