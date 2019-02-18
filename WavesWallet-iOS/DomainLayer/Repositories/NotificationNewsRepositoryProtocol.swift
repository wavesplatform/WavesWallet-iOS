//
//  ApplicationNewsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol NotificationNewsRepositoryProtocol  {

    func notificationNews() -> Observable<[DomainLayer.DTO.NotificationNews]>
}
