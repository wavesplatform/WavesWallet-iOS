//
//  ApplicationVersionRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol ApplicationVersionRepositoryProtocol {
    func version() -> Observable<String>
    func forceUpdateVersion() -> Observable<String>
}
