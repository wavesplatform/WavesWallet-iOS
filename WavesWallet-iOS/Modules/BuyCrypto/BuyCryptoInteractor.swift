// 
//  BuyCryptoInteractor.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxCocoa
import RxSwift

final class BuyCryptoInteractor: BuyCryptoInteractable {
    private let presenter: BuyCryptoPresentable
    
    private let stateTransformTrait: StateTransformTrait<BuyCryptoState>
    
    private let apiResponse = ApiResponse()
    
    private let disposeBag = DisposeBag()
    
    init(presenter: BuyCryptoPresentable) {
        self.presenter = presenter
        
        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        self.stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
    }
    
    private func performInitialLoading() {
        
    }
}

// MARK: - IOTransformer

extension BuyCryptoInteractor: IOTransformer {
    func transform(_ input: BuyCryptoViewOutput) -> BuyCryptoInteractorOutput {
        input.viewWillAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.performInitialLoading() })
            .disposed(by: disposeBag)
        
        StateTransform.fromIsLoadingToACashAssetsLoaded(stateTransformTrait: stateTransformTrait,
                                                        didLoadACashAssets: apiResponse.didLoadACashAssets)
        
        StateTransform.fromIsLoadingToLoadingError(stateTransformTrait: stateTransformTrait,
                                                   aCashAssetsLoadingError: apiResponse.aCashAssetsLoadingError)
        
        StateTransform.fromLoadingErrorToIsLoading(stateTransformTrait: stateTransformTrait, didTapRetry: input.didTapRetry)
        
        return BuyCryptoInteractorOutput(readOnlyState: stateTransformTrait.readOnlyState)
    }
}

extension BuyCryptoInteractor {
    private enum StateTransform {
        static func fromIsLoadingToACashAssetsLoaded(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                     didLoadACashAssets: Observable<Void>) {
            
        }
        
        static func fromIsLoadingToLoadingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                aCashAssetsLoadingError: Observable<Error>) {
            let fromIsLoadingToLoadingError = aCashAssetsLoadingError
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .isLoading: return true
                    default: return false
                    }
            }
            .map { BuyCryptoState.loadingError($0.localizedDescription) }
            
            fromIsLoadingToLoadingError.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }
        
        static func fromLoadingErrorToIsLoading(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                didTapRetry: ControlEvent<Void>) {
            let fromLoadingErrorToIsLoading = didTapRetry
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .loadingError: return true
                    default: return false
                    }
            }
            .map { BuyCryptoState.isLoading }
            
            fromLoadingErrorToIsLoading.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }
    }
}

// MARK: - NetWorker

extension BuyCryptoInteractor {
    private final class Networker {
        
    }
}
