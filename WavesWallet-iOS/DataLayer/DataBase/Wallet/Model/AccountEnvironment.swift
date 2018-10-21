//
//  AccountEnvironment.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class AccountEnvironment: Object {

    @objc dynamic var nodeUrl: String?
    @objc dynamic var dataUrl: String?
    @objc dynamic var spamUrl: String?
    @objc dynamic var matcherUrl: String?    
}
