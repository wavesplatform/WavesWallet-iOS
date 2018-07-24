//
//  Observable+Types.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

/**
 AsyncObservable tooltip for the developer, then what AsyncObservable does not guarantee that it will be in the main stream
 */
typealias AsyncObservable<E> = Observable<E>
