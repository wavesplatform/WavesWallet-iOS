//
//  Observable+Extensions.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import RxCocoa
import RxSwift

extension ObservableType {
    public func compactMap<R>() -> Observable<R> where Element == R? {
        compactMap { $0 }
    }

    public func mapAsVoid() -> Observable<Void> {
        map { _ in Void() }
    }

    /// Оператор нужен для случаев, когда .asSignal(onErrorJustReturn:) не получается использовать
    /// Если можно использовать стандартный оператор .asSignal(onErrorJustReturn:), то лучше использовать его
    public func asSignalIgnoringError() -> Signal<Element> {
        let signal = map { element -> Element? in element }.asSignal(onErrorJustReturn: nil).compactMap()
        return signal
    }

    /// Оператор нужен для случаев, когда .asDriver(onErrorJustReturn:) не получается использовать
    /// Если можно использовать стандартный оператор .asDriver(onErrorJustReturn:), то лучше использовать его
    public func asDriverIgnoringError() -> Driver<Element> {
        let signal = map { element -> Element? in element }.asDriver(onErrorJustReturn: nil).compactMap()
        return signal
    }
}

extension SharedSequenceConvertibleType {
    /// Для Driver'ов и Signal'ов
    public func compactMap<R>() -> RxCocoa.SharedSequence<Self.SharingStrategy, R> where Self.Element == R? {
        compactMap { $0 }
    }

    public func mapAsVoid() -> RxCocoa.SharedSequence<Self.SharingStrategy, Void> {
        map { _ in Void() }
    }
}

extension ControlEvent where Element == String? {
    public func orEmpty() -> ControlEvent<String> {
        let event = map { maybeText in maybeText ?? "" }
        return ControlEvent<String>(events: event)
    }
}

extension PublishRelay {
    public func asControlEvent() -> ControlEvent<Element> {
        ControlEvent(events: self)
    }
}

// MARK: -

extension ObservableType {
    /// Оператор для случаев, когда в интеракторе необходимо фильтровать событие текущим состоянием. Например когда нажатие
    /// кнопки допустимо только в состоянии dataLoaded.
    /// Заменяет собой комбинацию операторов withLatestFrom + filter + map.
    ///
    /// ```
    /// event
    ///    .withLatestFrom(readonlyState, resultSelector: latestFromBothValues())
    ///    .filter { _, state in
    ///        switch state {
    ///        case .isLoading: return true
    ///        default: return false
    ///        }
    ///    }
    ///    .map { value, _ in value }
    /// ```
    public func filteredByState<State>(_ state: Observable<State>,
                                       filter predicate: @escaping (State) -> Bool) -> Observable<Element> {
        let predicateAdapter: (Element, State) -> Bool = { _, state -> Bool in
            predicate(state)
        }

        return withLatestFrom(state, resultSelector: latestFromBothValues())
            .filter(predicateAdapter)
            .map { value, _ in value }
    }

    /// Оператор для случаев, когда в интеракторе необходимо фильтровать событие текущим состоянием. Например когда нажатие
    /// кнопки допустимо только в состоянии dataLoaded.
    /// Заменяет собой комбинацию операторов withLatestFrom + filter + map.
    ///
    /// Вместо оператора filter используется оператор compactMap, который выполняет ту же самую роль.
    /// Это нужно в случаях, когда вместе с филтрацией требуется также извлечь данные из конкретного состояния.
    /// Если проводить аналогию с работой filter(), то значение типа U эквивалентно true, а nil эквивалентен false
    ///
    /// ```
    /// retryButtonTap
    ///   .withLatestFrom(readonlyState, resultSelector: latestFromBothValues())
    ///   .compactMap { _, state -> String? in
    ///     switch state {
    ///     case .requestError(_, smsCode): return smsCode
    ///     default: return nil
    ///     }
    ///   }
    /// ```
    public func filteredByState<State, U>(_ state: Observable<State>,
                                          compactMap: @escaping (State) -> U?) -> Observable<(Element, U)> {
        let compactMapAdapter: (Element, State) -> (Element, U)? = { element, state -> (Element, U)? in
            let maybeOutput = compactMap(state)
            return maybeOutput.map { (element, $0) } // Элемент SO + результат функции compactMap
        }

        return withLatestFrom(state, resultSelector: latestFromBothValues())
            .compactMap(compactMapAdapter)
    }
}

// MARK: - Denestify

// swiftlint:disable large_tuple

public func denestify<A, B, C>(tuple: ((A, B), C)) -> (A, B, C) {
    let ((a, b), c) = tuple
    return (a, b, c)
}

public func denestify<A, B, C>(tuple: (A, (B, C))) -> (A, B, C) {
    let (a, (b, c)) = tuple
    return (a, b, c)
}

public func denestify<A, B, C, D>(tuple: ((A, B), (C, D))) -> (A, B, C, D) {
    let ((a, b), (c, d)) = tuple
    return (a, b, c, d)
}

public func denestify<A, B, C, D>(tuple: (A, (B, C), D)) -> (A, B, C, D) {
    let (a, (b, c), d) = tuple
    return (a, b, c, d)
}

public func denestify<A, B, C, D>(tuple: ((A, B, C), D)) -> (A, B, C, D) {
    let ((a, b, c), d) = tuple
    return (a, b, c, d)
}

public func denestify<A, B, C, D>(tuple: (A, (B, C, D))) -> (A, B, C, D) {
    let (a, (b, c, d)) = tuple
    return (a, b, c, d)
}

extension ObservableType {
    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C>() -> Observable<(A, B, C)> where Element == ((A, B), C) {
        map { denestify(tuple: $0) }
    }

    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C>() -> Observable<(A, B, C)> where Element == (A, (B, C)) {
        map { denestify(tuple: $0) }
    }

    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C, D>() -> Observable<(A, B, C, D)> where Element == ((A, B), (C, D)) {
        map { denestify(tuple: $0) }
    }

    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C, D>() -> Observable<(A, B, C, D)> where Element == (A, (B, C), D) {
        map { denestify(tuple: $0) }
    }

    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C, D>() -> Observable<(A, B, C, D)> where Element == ((A, B, C), D) {
        map { denestify(tuple: $0) }
    }

    /// Убирает вложенность из картэжей
    public func denestifyTuple<A, B, C, D>() -> Observable<(A, B, C, D)> where Element == (A, (B, C, D)) {
        map { denestify(tuple: $0) }
    }
}
