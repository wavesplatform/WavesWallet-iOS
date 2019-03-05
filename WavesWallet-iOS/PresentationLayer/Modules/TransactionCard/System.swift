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

    var inputEvent: PublishSubject<SystemType.Event> { get }

    var disposeBag: DisposeBag { get }

    func update(state: SystemType.State)
}

extension ControlSystem {

    func startSystem(sideEffects: [Observable<SystemType.Event>]) {

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

protocol System {

    associatedtype State

    associatedtype Event

    typealias Feedback = (Driver<State>) -> Signal<Event>

    func start(sideEffects: [Feedback]) -> Driver<State>

    func internalSideEffects() -> [Feedback]

    static var initialState: State { get }

    static func reduce(event: Event, state: inout State) -> State
}

extension System {

    func start() -> Driver<State> {
        return start(sideEffects: [])
    }

    func start(sideEffects: [Observable<Event>]) -> Driver<State> {

        let feedback: Feedback = react(query: { $0 }) { _ -> Signal<Event> in
            return Observable.merge(sideEffects).asSignal(onErrorSignalWith: Signal.empty())
        }

        return start(sideEffects: [feedback])
    }

    func start(sideEffects: [Feedback]) -> Driver<State> {

        var newSideEffects = sideEffects
        newSideEffects.append(contentsOf: internalSideEffects())

        let system = Driver
            .system(initialState: Self.initialState,
                    reduce: { state, event -> Self.State in
                        var newState = state
                        return Self.reduce(event: event, state: &newState)
            },
                    feedback: newSideEffects)

        return system
    }
}
