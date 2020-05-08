//
//  PublishObservableWrapper.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import RxCocoa
import RxSwift

/// Обертка, которая позволяет использовать PublishSubject как Observable.
/// Это нужно в случаях, когда accept элементов делается только в 1 месте, а подписки делаются в несколькизх местах.
/// Так сделано для того, чтобы по символу $ в начале названия было визуально заметно в каких местах происходит
/// передача элементов в реактивные стримы.
///
/// - wrappedValue – когда нужно только подписываться на поток данных, и возможность accept'ить не требуется.
/// Нужно, например, в имплементации StateTransform.
/// - projectedValue – когда нужно за-accept'ить данные в PublishSubject. Как правило, это нужно внутри самого интерактора.
@propertyWrapper
public final class PublishObservable<Value> {
    public let wrappedValue: Observable<Value>

    public let projectedValue = PublishRelay<Value>()

    public init() {
        wrappedValue = projectedValue.asObservable()
    }
}
