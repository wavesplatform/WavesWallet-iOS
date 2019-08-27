//
//  WidgetEnvironment.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DataLayer

final class WidgetEnvironment {
    
    private(set) lazy var environmentRepository = EnvironmentRepository()
    static var shared: WidgetEnvironment = WidgetEnvironment()
}
