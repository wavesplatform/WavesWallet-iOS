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
import WavesSDKExtensions

open class System<S, E> {

    public typealias State = S

    public typealias Event = E

    public typealias Feedback = (Driver<State>) -> Signal<Event>

    private let inputEvent: PublishSubject<Event> = .init()

    public init() {}
        
    public func start(sideEffects: [Feedback]) -> Driver<State> {

        var newSideEffects = sideEffects

        let feedback: Feedback = react(request: { (state) -> Bool? in
            return true
        }) { [weak self] _ -> Signal<Event> in
            guard let self = self else { return Signal.empty() }
            return self.inputEvent.observeOn(MainScheduler.instance).asSignal(onErrorSignalWith: Signal.empty())
        }

        newSideEffects.append(feedback)
        newSideEffects.append(contentsOf: internalFeedbacks())

        let system = Driver
            .system(initialState: self.initialState(),
                    reduce: { [weak self] state, event -> State in

                        guard let self = self else { return state }

                        var newState = state
                        self.reduce(event: event, state: &newState)
                        return newState
                    },
                    feedback: newSideEffects)

        return system
    }

    public func send(_ event: Event) {
        inputEvent.onNext(event)
    }

    open func initialState() -> State! {
        assertMethodNeedOverriding()
        return nil
    }

    open func internalFeedbacks() -> [Feedback] {
        assertMethodNeedOverriding()
        return []
    }

    open func reduce(event: Event, state: inout State) {
        assertMethodNeedOverriding()
    }
}

public extension System {
    func start() -> Driver<State> {
        return start(sideEffects: [])
    }
}
