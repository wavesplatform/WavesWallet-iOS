//
//  AddressBookRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift

final class AddressBookRepository: AddressBookRepositoryProtocol {

    func contact(by address: String, accountAddress: String) -> Observable<DomainLayer.DTO.Contact?> {

        return Observable.create({ observer -> Disposable in

            //TODO: Remove !
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)

            if let object = realm.object(ofType: AddressBook.self, forPrimaryKey: address) {
                observer.onNext(DomainLayer.DTO.Contact(name: object.name, address: object.address))
            } else {
                observer.onNext(nil)
            }
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func listListener(by accountAddress: String) -> Observable<[DomainLayer.DTO.Contact]> {
        return Observable.create({ observer -> Disposable in
            //TODO: Remove !
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            let result = realm.objects(AddressBook.self)
            let collection = Observable.collection(from: result)
                .skip(1)
                .map { $0.toArray() }
                .map({ list -> [DomainLayer.DTO.Contact] in
                    return list.map { return DomainLayer.DTO.Contact(name: $0.name, address: $0.address) }
                })
                .bind(to: observer)
            
            return Disposables.create([collection])
        })
        .subscribeOn(Schedulers.realmThreadScheduler)
    }
    
    func list(by accountAddress: String) -> Observable<[DomainLayer.DTO.Contact]> {
        return Observable.create({ observer -> Disposable in

            //TODO: Remove !
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            let list = realm.objects(AddressBook.self).toArray().map {
                return DomainLayer.DTO.Contact(name: $0.name, address: $0.address)
            }
            observer.onNext(list)
            observer.onCompleted()
            
            return Disposables.create()
        })
    }

    func save(contact: DomainLayer.DTO.Contact, accountAddress: String) -> Observable<Bool> {

        return Observable.create({ observer -> Disposable in
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)

            //TODO: Remove !
            try! realm.write {
                realm.add(AddressBook(contact), update: true)
            }
            observer.onNext(true)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func delete(contact: DomainLayer.DTO.Contact, accountAddress: String) -> Observable<Bool> {

        return Observable.create({ observer -> Disposable in
            //TODO: Remove !
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)

            guard let user = realm.object(ofType: AddressBook.self,
                                          forPrimaryKey: contact.address) else {
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }

            try! realm.write {
                realm.delete(user)
            }

            observer.onNext(true)
            observer.onCompleted()

            return Disposables.create()
        })
    }
}

private extension AddressBook {
    
    convenience init(_ from: DomainLayer.DTO.Contact) {
        self.init()
        self.address = from.address
        self.name = from.name
    }
}
