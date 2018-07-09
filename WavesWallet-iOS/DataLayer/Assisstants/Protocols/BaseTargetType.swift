//
//  APIType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {}

extension BaseTargetType {

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
