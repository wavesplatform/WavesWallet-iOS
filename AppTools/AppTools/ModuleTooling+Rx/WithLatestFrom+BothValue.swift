//
//  WithLatestFrom+BothValue.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

/**
 Вовзращает замыкание для оператора .withLatestFrom(_:, resultSelector:)
 Замыкание возвращает те же самые параметры, что и получило
 Нужно для того, чтоб не писать этот код руками, т.к часто при использовании .withLatestFrom нужны
 данные из обоих исходных Observable
 **/
public func latestFromBothValues<F, S>() -> ((F, S) -> (F, S)) {
    let bothValuesResult: (F, S) -> (F, S) = { firstValue, secondValue in (firstValue, secondValue) }
    return bothValuesResult
}
