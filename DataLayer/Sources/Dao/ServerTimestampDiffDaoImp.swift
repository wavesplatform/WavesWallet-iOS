//
//  ServerTimestampDiffDaoImp.swift
//  DataLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

class ServerTimestampDiffDaoImp: ServerTimestampDiffDao {
    
    private var internalServerTimestampDiff: Int64?

    // TODO: Is need mutex?
    private var serverTimestampDiff: Int64? {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalServerTimestampDiff
        }
        
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalServerTimestampDiff = newValue
        }
    }
                 
    func serverTimestampDiffDao() -> Observable<Int64?> {
        return Observable.just(serverTimestampDiff)
    }
    
    func setServerTimestampDiffDao(_ value: Int64?) -> Observable<Int64?> {
        serverTimestampDiff = value
        return Observable.just(value)
    }
}


