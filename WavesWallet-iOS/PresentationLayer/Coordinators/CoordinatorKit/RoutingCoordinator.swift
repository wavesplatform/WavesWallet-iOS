//
//  RoutingCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

protocol RoutingCoordinator: Coordinator {
    associatedtype Router

    init(router: Router)
}
