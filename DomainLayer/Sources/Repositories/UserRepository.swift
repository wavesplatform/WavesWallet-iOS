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
    /// UID - уникальный индификатор всех аккаунтов пользователя
    func createNewUserId(wallet: SignedWallet) -> Observable<String>
    
    /// UID - добавить индификатор для аккаунта пользователя
    func associateUserIdWithUser(wallet: SignedWallet, uid: String) -> Observable<String>
    
    /// Проверка наличия рефераллов у пользователя
    func checkReferralAddress(wallet: SignedWallet) -> Observable<String?>
}
