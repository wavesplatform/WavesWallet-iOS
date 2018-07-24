//
//  ViewConfiguration.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol ViewConfiguration {
    associatedtype Model
    func update(with model: Model)
}

protocol ViewAnimatableConfiguration: ViewConfiguration {
    func update(with model: Model, animated: Bool)
}

extension ViewAnimatableConfiguration {
    func update(with model: Model) {
        update(with: model, animated: true)
    }
}
