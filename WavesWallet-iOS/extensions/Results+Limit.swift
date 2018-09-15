//
//  Results+Limit.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 11/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {

    func get<T: Object>(offset: Int, limit: Int) -> Array<T> {

        var lim = 0
        var off = 0
        var list: [T] = [T]()


        if off <= offset && offset < self.count - 1 {
            off = offset
        }

        if limit > self.count {
            lim = self.count
        } else {
            lim = limit
        }

        // do slicing
        for i in off..<lim {
            let object = self[i] as! T
            list.append(object)
        }

        return list
    }
}
