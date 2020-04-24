//
//  ServicesFactory.swift
//  DomainLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

final public class ServicesFactoryImp: ServicesFactory {
    
    private let wavesSDKServices: WavesSDKServices = WavesSDKServicesImp.shared
    
    public init() { }
    
    public private(set) lazy var timestampServerService: TimestampServerService = {
        return TimestampServerServiceImp(wavesSDKServices: wavesSDKServices)
    }()
}


