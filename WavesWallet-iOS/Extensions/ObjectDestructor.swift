
//
//  ObjectDestructor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class ObjectDestructor {

    let dealloc: (() -> Void)

    init(dealloc: @escaping (() -> Void)) {
        self.dealloc = dealloc
    }

    deinit {
        dealloc()
    }
}
