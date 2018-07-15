//
//  ControlEvent+Signal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ControlEvent {
    func asSignal() -> Signal<E> {
        return self.asObservable().asSignal(onErrorSignalWith: .empty())
    }
}
