//
//  UserRepository.swift
//  DomainLayer
//
//  Created by rprokofev on 14.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol UserRepository {
    func userUID(wallet: DomainLayer.DTO.SignedWallet) -> Observable<String>
    func setUserUID(wallet: DomainLayer.DTO.SignedWallet, uid: String) -> Observable<String>
}
