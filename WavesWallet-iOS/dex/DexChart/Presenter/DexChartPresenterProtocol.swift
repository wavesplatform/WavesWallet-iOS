//
//  DexChartPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexChartPresenterProtocol {
    typealias Feedback = (Driver<DexChart.State>) -> Signal<DexChart.Event>
    var interactor: DexChartInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
