//
//  System.swift
//  RemotePlace
//
//  Created by Prokofev Ruslan on 10/02/2019.
//  Copyright © 2019 RemotePlace. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

protocol ControlSystem: AnyObject {

    associatedtype SystemType: System

    var system: SystemType { get }

    var inputEvent: PublishSubject<Self.SystemType.Event> { get }

    var disposeBag: DisposeBag { get }

    func update(state: SystemType.State)
}

extension ControlSystem {

    func startSystem(sideEffects: [Observable<Self.SystemType.Event>]) {

        var newSideEffects = sideEffects
        newSideEffects.append(inputEvent.asObserver())

        system
            .start(sideEffects: newSideEffects)
            .drive(onNext: { [weak self] (state) in
                self?.update(state: state)
            })
            .disposed(by: disposeBag)
    }
}

protocol System: AnyObject {

    associatedtype State: Equatable

    associatedtype Event

    typealias Feedback = (Driver<State>) -> Signal<Event>

    func start(sideEffects: [Feedback]) -> Driver<State>

    var initialState: State { get }

    func reduce(event: Event, state: inout State)
}

extension System {

    func start() -> Driver<State> {
        return start(sideEffects: [])
    }

    func start(sideEffects: [Observable<Event>]) -> Driver<State> {
        
        let feedback: Feedback = react(request: { (state) -> State? in
            return state
        }) { (_) -> Signal<Event> in
            return Observable.merge(sideEffects).asSignal(onErrorSignalWith: Signal.empty())
        }

        return start(sideEffects: [feedback])
    }

    func start(sideEffects: [Feedback]) -> Driver<State> {

        let newSideEffects = sideEffects
//        newSideEffects.append(contentsOf: internalSideEffects())

        let system = Driver
            .system(initialState: self.initialState,
                    reduce: { [weak self] state, event -> Self.State in
                        var newState = state
                        self?.reduce(event: event, state: &newState)
                        return newState
                    },
                    feedback: newSideEffects)

        return system
    }
}
