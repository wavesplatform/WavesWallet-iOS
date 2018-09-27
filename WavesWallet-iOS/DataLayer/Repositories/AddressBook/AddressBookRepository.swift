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

    func listListener() -> Observable<[DomainLayer.DTO.Contact]> {
        return Observable.create({ observer -> Disposable in
            let realm = try! Realm()
            
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
    }
    
    func list() -> Observable<[DomainLayer.DTO.Contact]> {
        return Observable.create({ observer -> Disposable in
            let realm = try! Realm()
            
            let list = realm.objects(AddressBook.self).toArray().map {
                return DomainLayer.DTO.Contact(name: $0.name, address: $0.address)
            }
            observer.onNext(list)
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
    
    func create(contact: DomainLayer.DTO.Contact) {
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(addressBookContact(contact), update: true)
        }
    }
    
    func edit(contact: DomainLayer.DTO.Contact, newContact: DomainLayer.DTO.Contact) {
        
        let realm = try! Realm()

        if let contact = realm.object(ofType: AddressBook.self, forPrimaryKey: contact.address) {
            
            try! realm.write {
                realm.delete(contact)
                realm.add(addressBookContact(newContact), update: true)
            }
        }
    }
    
    func delete(contact: DomainLayer.DTO.Contact) {
        
        let realm = try! Realm()
        
        if let user = realm.object(ofType: AddressBook.self, forPrimaryKey: contact.address) {
            try! realm.write {
                realm.delete(user)
            }
        }
    }
}

private extension AddressBookRepository {
    
    func addressBookContact(_ from: DomainLayer.DTO.Contact) -> AddressBook {
        let addressBook = AddressBook()
        addressBook.address = from.address
        addressBook.name = from.name
        return addressBook
    }
}
