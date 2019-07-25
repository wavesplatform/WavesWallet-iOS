//
//  MarketPulsePair.swift
//  DataLayer
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class MarketPulsePair: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var pair: String = ""
}
