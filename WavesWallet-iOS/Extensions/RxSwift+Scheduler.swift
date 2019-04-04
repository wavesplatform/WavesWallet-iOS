//
//  RxSwift+Scheduler.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public var myDefaultScheduler: SchedulerType = MainScheduler.asyncInstance
public var myWorkScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)

extension ObservableType {

    /**
     Makes the observable Subscribe to io thread and Observe on main thread
     */
    public func composeIoToMainThreads() -> Observable<E> {
        return self.subscribeOn(myWorkScheduler)
            .observeOn(myDefaultScheduler)
    }

}
