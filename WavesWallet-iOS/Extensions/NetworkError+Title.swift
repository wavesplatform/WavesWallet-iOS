//
//  NetworkError.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 02.09.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDK

extension NetworkError {
    public var text: String {
        switch self {
        case .message(let message):
            return message

        case .internetNotWorking:
            return Localizable.Waves.General.Error.Title.noconnectiontotheinternet

        default:
            return Localizable.Waves.General.Error.Title.notfound
        }
    }
}
