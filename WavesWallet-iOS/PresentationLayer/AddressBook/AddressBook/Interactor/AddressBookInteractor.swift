//
//  AddressBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AddressBookInteractor: AddressBookInteractorProtocol {
    
    private let searchString: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
    private var _users: [DomainLayer.DTO.Contact] = []
    private let repository = AddressBookRepository()
    
    func users() -> Observable<[DomainLayer.DTO.Contact]> {
                
        let merge = Observable.merge([repository.list(), repository.listListener()])
            .do(onNext: { [weak self] users in
                self?._users = users
            })
        
        let search = searchString
            .asObserver().skip(1)
            .map { [weak self] searchString -> [DomainLayer.DTO.Contact] in
                return self?._users ?? []
            }
        
        return Observable
            .merge([merge, search])
            .map { [weak self] users -> [DomainLayer.DTO.Contact] in
                
                let searchText = (try? self?.searchString.value() ?? "") ?? ""
                
                let newUsers = users.filter {
                    self?.isValidSearch(userName: $0.name, searchText: searchText) ?? false
                }
                return newUsers
            }
    }

    func searchUser(searchText: String) {
        searchString.onNext(searchText)
    }
  
}

private extension AddressBookInteractor {
    
    func isValidSearch(userName: String, searchText: String) -> Bool {
        
        let searchWords = searchText.components(separatedBy: " ").filter {$0.count > 0}
        
        var validations: [Bool] = []
        for word in searchWords {
            validations.append((userName.lowercased() as NSString).range(of: word.lowercased()).location != NSNotFound)

        }
        return validations.filter({$0 == true}).count == searchWords.count
    }
}
