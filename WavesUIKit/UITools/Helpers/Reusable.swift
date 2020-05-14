//
//  Reusable.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
