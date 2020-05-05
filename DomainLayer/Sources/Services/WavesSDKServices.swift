//
//  WavesSDKServices.swift
//  DomainLayer
//
//  Created by rprokofev on 27.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK

public protocol WavesSDKServices {
    func wavesServices(environment: ServerEnvironment) -> WavesServicesProtocol
}
