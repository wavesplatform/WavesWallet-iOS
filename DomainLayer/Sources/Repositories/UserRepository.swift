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
    
    // UID - уникальный индификатор всех аккаунтов пользователя
    func userUID(wallet: DomainLayer.DTO.SignedWallet) -> Observable<String>
    // UID - добавить индификатор для аккаунта пользователя
    func setUserUID(wallet: DomainLayer.DTO.SignedWallet, uid: String) -> Observable<String>
}
