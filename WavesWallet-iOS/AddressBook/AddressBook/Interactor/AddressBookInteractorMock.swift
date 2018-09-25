//
//  AddressBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AddressBookInteractorMock: AddressBookInteractorProtocol {
    
    private static var allUsers: [DomainLayer.DTO.User] = []
    private static var searchUsers: [DomainLayer.DTO.User] = []
    
    private let searchUsersSubject: PublishSubject<[DomainLayer.DTO.User]> = PublishSubject<[DomainLayer.DTO.User]>()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    func getAllUsers() -> Observable<[DomainLayer.DTO.User]> {
        AddressBookInteractorMock.allUsers = allUsers()
        return Observable.just(AddressBookInteractorMock.allUsers)
    }
    
    func getSearchUsers() -> Observable<[DomainLayer.DTO.User]> {
        return searchUsersSubject.asObserver()
    }
    
    func searchUser(searchText: String) {
        
        AddressBookInteractorMock.searchUsers.removeAll()
        
        if searchText.count > 0 {
            
            AddressBookInteractorMock.searchUsers = AddressBookInteractorMock.allUsers.filter {
                searchUser(userName: $0.name, searchText: searchText)
            }
            
            searchUsersSubject.onNext(AddressBookInteractorMock.searchUsers)
        }
        else {
            searchUsersSubject.onNext(AddressBookInteractorMock.allUsers)
        }
    }
}


private extension AddressBookInteractorMock {
    
    func searchUser(userName: String, searchText: String) -> Bool {
        
        let searchWords = searchText.components(separatedBy: " ").filter {$0.count > 0}
        
        var validations: [Bool] = []
        for word in searchWords {
            validations.append(isValidSearch(inputText: userName, searchText: word))
        }
        return validations.filter({$0 == true}).count == searchWords.count
    }
    
    func isValidSearch(inputText: String, searchText: String) -> Bool {
        return (inputText.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
    }
}


//MARK: - TestData
private extension AddressBookInteractorMock {
    
    func allUsers() -> [DomainLayer.DTO.User] {
        
        let address = "MkSuckMydickmMak1593x1GrfYmFdsf83skS11"
        var users: [DomainLayer.DTO.User] = []
        
        users.append(.init(name: "Alex Jeff", address: address))
        users.append(.init(name: "Bob", address: address))
        users.append(.init(name: "Big Boobs", address: address))
        users.append(.init(name: "Bork Adam", address: address))
        users.append(.init(name: "MaksTorch", address: address))
        users.append(.init(name: "Mr. Big Mike", address: address))
        users.append(.init(name: "Ms. Jane", address: address))
        return users
    }
}
