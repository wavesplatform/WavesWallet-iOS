//
//  StateTrait.swift
//  AppTools
//
//  Created by vvisotskiy on 18.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import RxCocoa
import RxSwift

/// Необходим для передачи постоянных параметров в методы StateTransform
public struct StateTransformTrait<State> {
    public let readOnlyState: Observable<State>
    public let _state: BehaviorRelay<State>
    
    public let disposeBag: DisposeBag
    
    public init(_state: BehaviorRelay<State>, disposeBag: DisposeBag) {
        readOnlyState = _state.asObservable()
        self._state = _state
        
        self.disposeBag = disposeBag
    }
}
