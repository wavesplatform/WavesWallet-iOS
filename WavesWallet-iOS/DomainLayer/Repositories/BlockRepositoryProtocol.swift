//
//  BlockRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum BlockRepositoryError: Error {
    case fail
}

protocol BlockRepositoryProtocol {
    func height() -> Observable<Int64>
}
