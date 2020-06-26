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
    weak var listener: WelcomeScreenListener?
    
    private let presenter: WelcomeScreenPresentable
    
    private let disposeBag = DisposeBag()
    
    init(presenter: WelcomeScreenPresentable) {
        self.presenter = presenter
    }
}

// MARK: - IOTransformer

extension WelcomeScreenInteractor: IOTransformer {
    func transform(_ input: WelcomeScreenViewOutput) -> WelcomeScreenInteractorOutput {
        input.didTapUrl
            .subscribe(onNext: { [weak self] url in self?.listener?.openURL(url) })
            .disposed(by: disposeBag)
        
        input.didTapBegin
            .subscribe(onNext: { [weak self] in self?.listener?.didTapBegin() })
            .disposed(by: disposeBag)
        
        return WelcomeScreenInteractorOutput(viewWillAppear: input.viewWillAppear)
    }
}
