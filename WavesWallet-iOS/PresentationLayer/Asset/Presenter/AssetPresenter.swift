//
//  AssetViewPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

final class AssetPresenter: AssetPresenterProtocol {

    private var disposeBag: DisposeBag = DisposeBag()
    
    var interactor: AssetInteractorProtocol!
    var moduleOutput: AssetModuleOutput?

    let input: AssetModuleInput

    init(input: AssetModuleInput) {
        self.input = input
    }

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(assetsQuery())

        let initialState = self.initialState(input: input)
        let system = Driver.system(initialState: initialState,
                                   reduce: AssetPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .drive(onNext: { [weak self] state in
                self?.handlerEventOutput(state: state)
            })
            .disposed(by: disposeBag)
    }

    private func assetsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.displayState.isAppeared == true
        }, effects: { [weak self] _ -> Signal<AssetTypes.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            let ids = strongSelf.input.assets.map { $0.id }

            return strongSelf
                .interactor
                .assets(by: ids)
                .map { AssetTypes.Event.setAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    func handlerEventOutput(state: AssetTypes.State) {
        guard let event = state.event else { return }

        switch event {
        default:
            break
        }
    }
}

// MARK: Core State

private extension AssetPresenter {

    class func reduce(state: AssetTypes.State, event: AssetTypes.Event) -> AssetTypes.State {

        switch event {
        case .readyView:

            return state.mutate {
                $0.displayState = $0.displayState.mutate {
                    $0.isAppeared = true
                    $0.action = .refresh
                }
            }

        case .changedAsset(let assetId):

            return state.mutate(transform: { state in

                if state.displayState.currentAsset.id == assetId {
                    state.displayState.action = .none
                    return
                }

                let currentAsset = state.assets.first(where: { $0.info.id == assetId })
                if let currentAsset = currentAsset {
                    state.displayState.currentAsset = currentAsset.info
                    state.displayState.sections = currentAsset.toSections()
                    state.displayState.action = .changedCurrentAsset
                } else {
                    state.displayState.action = .none
                }
            })

        case .setAssets(let assets):

            return state.mutate { state in

                var asset = assets.first(where: { asset -> Bool in
                    return asset.info.id == state.displayState.currentAsset.id
                })

                if asset == nil {
                   asset = assets.first
                }

                if let asset = asset {
                    state.displayState.sections = asset.toSections()
                    state.displayState.action = .refresh
                    state.displayState.currentAsset = asset.info
                    state.displayState.isUserInteractionEnabled = true
                    state.assets = assets
                } else {
                    state.displayState.sections = []
                    state.displayState.action = .none
                }
                state.displayState.assets = assets.map { $0.info }
                state.assets = assets
            }

        case .tapFavorite(let on):

            return state.mutate {
                $0.displayState.isFavorite = on
                $0.displayState.action = .changedFavorite
            }

        default:
            break
        }

        return state.mutate {
            $0.displayState = $0.displayState.mutate {
                $0.action = .none
            }
        }
    }
}

// MARK: UI State

fileprivate extension AssetTypes.DTO.Asset {

    func toSections() -> [AssetTypes.ViewModel.Section] {

        let balance: AssetTypes.ViewModel.Section = .init(kind: .none, rows: [.balance(self.balance)])
        let transactions: AssetTypes.ViewModel.Section = .init(kind: .title("Last transactions"), rows: [.transactionSkeleton, .viewHistory, .viewHistoryDisabled])
        let assetInfo: AssetTypes.ViewModel.Section =   .init(kind: .none, rows: [.assetInfo(self.info)])

        return [balance,
                transactions,
                assetInfo]
    }
}

// MARK: UI State

private extension AssetPresenter {

    func initialState(input: AssetModuleInput) -> AssetTypes.State {
        return AssetTypes.State(event: nil, assets: [], displayState: initialDisplayState(input: input))
    }

    func initialDisplayState(input: AssetModuleInput) -> AssetTypes.DisplayState {

        let balances = AssetTypes.ViewModel.Section.init(kind: .none, rows: [.balanceSkeleton])
        let transactions = AssetTypes.ViewModel.Section.init(kind: .skeletonTitle, rows: [.transactionSkeleton, .viewHistorySkeleton])

        return AssetTypes.DisplayState(isAppeared: false,
                                       isRefreshing: false,
                                       isFavorite: false,
                                       isUserInteractionEnabled
            : false,
                                       currentAsset: input.currentAsset,
                                       assets: input.assets,
                                       sections: [balances,
                                                  transactions],
                                       action: .refresh)
    }
}
