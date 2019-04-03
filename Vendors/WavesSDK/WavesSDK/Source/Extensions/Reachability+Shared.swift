//
//  Reachability+Shared.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Reachability

public enum ReachabilityService {
    static var instance: Reachability = {
        let reachability = Reachability()!
        try? reachability.startNotifier()
        return reachability
    }()
}
