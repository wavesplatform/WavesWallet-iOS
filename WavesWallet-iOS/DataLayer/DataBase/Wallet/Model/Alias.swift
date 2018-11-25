//
//  Alias.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class Alias: Object {    
    @objc dynamic var name: String = ""
    @objc dynamic var originalName: String = ""

    override static func primaryKey() -> String? {
        return "name"
    }
}
