//
//  AddressBookRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AddressBookRepositoryProtocol {
    
    func create(contact: DomainLayer.DTO.Contact)
    func edit(contact: DomainLayer.DTO.Contact, newContact: DomainLayer.DTO.Contact)
    func delete(contact: DomainLayer.DTO.Contact)
    func list() -> Observable<[DomainLayer.DTO.Contact]>
    func listListener() -> Observable<[DomainLayer.DTO.Contact]>
}
