//
//  AddressBookInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AddressBookInteractorProtocol {

    func users() -> Observable<[DomainLayer.DTO.Contact]>
    func searchUser(searchText: String)
}
