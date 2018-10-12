//
//  DatabaseReference+Rx.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import RxSwift

private enum Constants {
    static let timeoutInterval: TimeInterval = 30
}

extension Reactive where Base: DatabaseReference {

    func removeValue() -> Observable<DatabaseReference> {
        return Observable.create { observer -> Disposable in

            self.base.removeValue { error, reference in

                DispatchQueue.global().async {
                    if let error = error {
                        observer.onNext(reference)
                        observer.onError(error)
                    } else {
                        observer.onNext(reference)
                        observer.onCompleted()
                    }
                }
            }

            return Disposables.create()
        }
        .amb(Observable.error(NSError(domain: NSURLErrorDomain,
                                      code: NSURLErrorTimedOut,
                                      userInfo: nil))
        .delaySubscription(Constants.timeoutInterval, scheduler: MainScheduler.asyncInstance))
        .sweetDebug("FB removeValue")
    }

    func setValue(_ value: Any?) -> Observable<DatabaseReference> {
        return Observable.create { observer -> Disposable in

            self.base.setValue(value) { error, reference in
                DispatchQueue.global().async {
                    if let error = error {
                        observer.onNext(reference)
                        observer.onError(error)
                    } else {
                        observer.onNext(reference)
                        observer.onCompleted()
                    }
                }
            }

            return Disposables.create()
        }
        .amb(Observable.error(NSError(domain: NSURLErrorDomain,
                                      code: NSURLErrorTimedOut,
                                      userInfo: nil))
        .delaySubscription(Constants.timeoutInterval, scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())))
        .sweetDebug("FB setValue")
    }

    var value: Observable<Any?> {
        return Observable.create { observer -> Disposable in

            DispatchQueue.global().async {
                self.base.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { snapshot, _ in
                    observer.onNext(snapshot.value)
                    observer.onCompleted()
                }, withCancel: { error in
                    observer.onError(error)
                    observer.onCompleted()
                })
            }
            return Disposables.create()
        }
        .amb(Observable.error(NSError(domain: NSURLErrorDomain,
                                        code: NSURLErrorTimedOut,
                                        userInfo: nil))
        .delaySubscription(Constants.timeoutInterval, scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())))
        .sweetDebug("FB Value")
    }

}
