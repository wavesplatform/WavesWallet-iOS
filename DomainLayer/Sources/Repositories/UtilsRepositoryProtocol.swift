//
//  UtilsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/12/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol UtilsRepositoryProtocol {
    func timestampServerDiff(accountAddress: String) -> Observable<Int64>
}
