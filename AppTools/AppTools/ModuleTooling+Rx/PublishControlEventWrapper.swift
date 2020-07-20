//
//  PublishControlEventWrapper.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import RxCocoa
import RxSwift

/// Обертка, которая позволяет использовать PublishSubject как ControlEvent.
/// Это нужно в случаях, когда accept элементов делается только во ViewController'e, а подписки делаются в StateTransform.
/// Так сделано для того, чтобы по символу $ в начале названия было визуально заметно в каких местах происходит
/// передача элементов в реактивные стримы.
///
/// - wrappedValue – когда нужно только подписываться на поток данных, и возможность accept'ить не требуется.
/// Нужно, например, в имплементации StateTransform.
/// - projectedValue – когда нужно за-accept'ить данные в PublishSubject. Как правило, это нужно внутри ViewController'а.
@propertyWrapper
public final class PublishControlEvent<Value> {
    public let wrappedValue: ControlEvent<Value>
    
    public let projectedValue = PublishRelay<Value>()
    
    public init() {
        wrappedValue = projectedValue.asControlEvent()
    }
}
