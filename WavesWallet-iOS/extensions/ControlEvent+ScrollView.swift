//
//  ControlEvent+ScrollView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

extension Reactive where Base: UIScrollView {

    var didEndScroll: ControlEvent<Void> {
        let events = base.rx
            .didEndDragging
            .flatMap(weak: base) { owner, isDecelerate -> Observable<Void> in
                if isDecelerate {
                    return owner.rx.didEndDecelerating.take(1).asObservable()
                }
                return Observable.just(())
            }

        return ControlEvent<Void>(events: events)
    }

    func didRefreshing(refreshControl: UIRefreshControl) -> ControlEvent<Void> {

        let didEndScroll = base
            .rx
            .didEndScroll

        let refreshControlValueChanged = refreshControl
            .rx
            .controlEvent(.valueChanged)

        let refreshEvent = refreshControlValueChanged.flatMapLatest { _ -> Observable<Void> in
            return didEndScroll.asObservable().take(1)
        }

        return ControlEvent<Void>(events: refreshEvent)
    }
}
