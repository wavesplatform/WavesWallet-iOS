//
//  AddressBookInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AddressBookInteractor: AddressBookInteractorProtocol {

    func getAllUsers() -> Observable<[AddressBook.DTO.User]> {
        return Observable.empty()
    }
    
    func getSearchUsers() -> Observable<[AddressBook.DTO.User]> {
        return Observable.empty()
    }
    
    func searchUser(searchText: String) {
        
    }
}
