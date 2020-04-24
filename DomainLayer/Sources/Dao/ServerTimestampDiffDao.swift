//
//  ServerTimestampDiffDao.swift
//  DomainLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol ServerTimestampDiffDao {
    
    func serverTimestampDiffDao() -> Observable<Int64?>
    
    func setServerTimestampDiffDao(_ value: Int64?) -> Observable<Int64?>
}
