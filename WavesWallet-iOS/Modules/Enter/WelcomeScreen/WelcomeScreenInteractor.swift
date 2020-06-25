// 
//  WelcomeScreenInteractor.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxSwift

final class WelcomeScreenInteractor: WelcomeScreenInteractable {
    private let presenter: WelcomeScreenPresentable
    init(presenter: WelcomeScreenPresentable) {
        self.presenter = presenter
    }
}

// MARK: - IOTransformer

extension WelcomeScreenInteractor: IOTransformer {
    func transform(_ input: WelcomeScreenViewOutput) -> WelcomeScreenInteractorOutput {
        return WelcomeScreenInteractorOutput(viewWillAppear: input.viewWillAppear)
    }
}
