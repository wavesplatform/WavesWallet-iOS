//
//  ModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ModuleBuilder {
    associatedtype Input
    func build(input: Input) -> UIViewController
}

extension ModuleBuilder where Input == Void {
    func build() -> UIViewController {
        return build(input: ())
    }
}
