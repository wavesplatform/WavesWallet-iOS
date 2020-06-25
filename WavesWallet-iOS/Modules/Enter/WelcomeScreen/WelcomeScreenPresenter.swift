// 
//  WelcomeScreenPresenter.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxSwift

final class WelcomeScreenPresenter: WelcomeScreenPresentable {}

// MARK: - IOTransformer

extension WelcomeScreenPresenter: IOTransformer {
    func transform(_ input: WelcomeScreenInteractorOutput) -> WelcomeScreenPresenterOutput {
        let viewModel = input.viewWillAppear
            .map { _ -> [WelcomeScreenViewModel] in [.hello, .easyRefill, .invesmentInfo, .termOfConditions] }
            .asDriverIgnoringError()
        
        return WelcomeScreenPresenterOutput(viewModel: viewModel)
    }
}
