//
//  AccountSettings.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

class AccountSettings: Object {
    @objc dynamic var isEnabledSpam: Bool = false
}
