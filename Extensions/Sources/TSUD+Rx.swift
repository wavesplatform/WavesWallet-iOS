//
//  TSUD+Rx.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import RxSwift
import WavesSDKExtensions

public extension Reactive where Base: TSUD {
    
    public static func get(_ nsud: UserDefaults = .standard) -> Observable<Base.ValueType> {
        
        return Observable.create({ (subscribe) -> Disposable in
          
            subscribe.onNext(Base.init()[nsud])
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    public static func set(_ value: Base.ValueType, _ nsud: UserDefaults = .standard) -> Observable<Bool>{
        
        return Observable.create({ (subscribe) -> Disposable in
            
            Base.init()[nsud] = value
            subscribe.onNext(true)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
}
