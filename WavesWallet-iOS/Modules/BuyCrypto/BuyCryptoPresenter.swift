// 
//  BuyCryptoPresenter.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxCocoa
import RxSwift

final class BuyCryptoPresenter: BuyCryptoPresentable {}

// MARK: - IOTransformer

extension BuyCryptoPresenter: IOTransformer {
    func transform(_ input: BuyCryptoInteractorOutput) -> BuyCryptoPresenterOutput {
        let contentVisible = input.readOnlyState
            .map { state -> Bool in
                switch state {
                case .isLoading: return false
                default: return true
                }
        }
        .asDriver(onErrorJustReturn: true)
        
        let isLoadingIndicator = input.readOnlyState
            .map { state -> Bool in
                switch state {
                case .isLoading: return true
                default: return false
                }
        }
        .asDriver(onErrorJustReturn: false)
        
        let showError = input.readOnlyState
            .compactMap { state -> String? in
                switch state {
                case .loadingError(let errorMessage): return errorMessage
                default: return nil
                }
        }
        .asSignalIgnoringError()
        
        let validationError = Signal<String?>.never()
        
        return BuyCryptoPresenterOutput(contentVisible: contentVisible,
                                        isLoadingIndicator: isLoadingIndicator,
                                        error: showError,
                                        validationError: validationError)
    }
}
