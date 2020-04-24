//
//  ServicesFactoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public protocol ServicesFactory {

    var timestampServerService: TimestampServerService { get }
}
