//
//  BlockRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public enum BlockRepositoryError: Error {
    case fail
}

public protocol BlockRepositoryProtocol {
    func height(accountAddress: String) -> Observable<Int64>
}
