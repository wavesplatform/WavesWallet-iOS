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

    func contact(by address: String, accountAddress: String) -> Observable<DomainLayer.DTO.Contact?>
    func save(contact: DomainLayer.DTO.Contact, accountAddress: String) -> Observable<Bool>
    func delete(contact: DomainLayer.DTO.Contact, accountAddress: String) -> Observable<Bool>
    func list(by accountAddress: String) -> Observable<[DomainLayer.DTO.Contact]>
    func listListener(by accountAddress: String) -> Observable<[DomainLayer.DTO.Contact]>
}
