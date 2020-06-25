//
//  TitledBool.swift
//  AppTools
//
//  Created by vvisotskiy on 22.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

public struct TitledBool: Hashable {
    public let title: String
    public let isOn: Bool
    
    public init(title: String, isOn: Bool) {
        self.title = title
        self.isOn = isOn
    }
}

extension TitledBool {
    public func copy(newIsOn: Bool) -> TitledBool {
        TitledBool(title: title, isOn: newIsOn)
    }
}
