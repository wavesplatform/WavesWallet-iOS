//
//  IdentifiableType+Hashable.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

extension IdentifiableType where Self: Hashable {
    var identity: String { return "\(hashValue)" }
}
