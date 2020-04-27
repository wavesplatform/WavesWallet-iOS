//
//  ServicesFactory.swift
//  DomainLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation

public final class ServicesFactoryImp: ServicesFactory {
            
    
    public private(set) lazy var wavesSDKServices: WavesSDKServices = {
        return WavesSDKServicesImp()
    }()
    
    public private(set) lazy var timestampServerService: TimestampServerService = {
        TimestampServerServiceImp(wavesSDKServices: wavesSDKServices)
    }()

    public private(set) lazy var spamAssetsService: SpamAssetsService = {
        return SpamAssetsServiceImp()
    }()
    
    public init() {}
}
