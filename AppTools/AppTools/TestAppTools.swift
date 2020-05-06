//
//  TestAppTools.swift
//  AppTools
//
//  Created by vvisotskiy on 06.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation
import RxSwift

public struct A {
    public let a: Observable<Int> = .just(1)
    
    public init() {}
}
