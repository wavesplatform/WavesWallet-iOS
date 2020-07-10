//
//  ModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public protocol ModuleBuilder {
    associatedtype Input
    associatedtype ViewController: UIViewController
    
    func build(input: Input) -> ViewController
}

public extension ModuleBuilder where Input == Void, ViewController: UIViewController {
    func build() -> ViewController {
        return build(input: ())
    }
}
