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
    weak var moduleOutput: AssetModuleOutput?

    let input: AssetModuleInput

    init(input: AssetModuleInput) {
        self.input = input
    }

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(assetsQuery())
        newFeedbacks.append(transactionsQuery())

        let initialState = self.initialState(input: input)

        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> AssetTypes.State in
                                        return self?.reduce(state: state, event: event) ?? state
                                    },
                                   feedback: newFeedbacks)

        system
            .drive()
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

    private func transactionsQuery() -> Feedback {
        return react(query: { state -> String? in

            guard state.displayState.isAppeared == true else { return nil }
            guard state.transactionStatus.isLoading == true else { return nil }

            return state.displayState.currentAsset.id

        }, effects: { [weak self] id -> Signal<AssetTypes.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor.transactions(by: id)
                .map { AssetTypes.Event.setTransactions($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}

// MARK: Core State

private extension AssetPresenter {

    func reduce(state: AssetTypes.State, event: AssetTypes.Event) -> AssetTypes.State {

        switch event {
        case .tapTransaction(let tx):
            self.moduleOutput?.showTransaction(tx)

        case .tapHistory:
            self.moduleOutput?.showHistory(by: state.displayState.currentAsset.id)
            
        case .readyView:

            return state.mutate {
                $0.displayState = $0.displayState.mutate {
                    $0.isAppeared = true
                    $0.action = .refresh
                }
            }

        case .refreshing:

            let ids = state.assets.map { $0.info.id }
            interactor.refreshAssets(by: ids)

            return state.mutate {
                $0.displayState = $0.displayState.mutate {
                    $0.isRefreshing = true
                    $0.action = .none
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
                    state.transactionStatus = .loading
                    state.displayState.currentAsset = currentAsset.info
                    state.displayState.sections = mapTosections(from: currentAsset,
                                                                and: state.transactionStatus)
                    state.displayState.isFavorite = currentAsset.info.isFavorite
                    state.displayState.action = .changedCurrentAsset
                } else {
                    state.displayState.action = .none
                }
            })

        case .setTransactions(let transactions):

            return state.mutate {

                let currentAsset = state.assets.first(where: { asset -> Bool in
                    return asset.info.id == state.displayState.currentAsset.id
                })

                if let asset = currentAsset {
                    $0.transactionStatus = transactions.count == 0 ? .empty : .transaction(transactions)

                    $0.displayState.sections = mapTosections(from: asset,
                                                             and: $0.transactionStatus)
                    $0.displayState.action = .refresh
                } else {
                    $0.displayState.action = .none
                }
            }

        case .setAssets(let assets):

            return state.mutate { state in

                var asset = assets.first(where: { asset -> Bool in
                    return asset.info.id == state.displayState.currentAsset.id
                })

                if asset == nil {
                   asset = assets.first
                }

                if let asset = asset {
                    state.transactionStatus = .loading
                    state.displayState.sections = mapTosections(from: asset,
                                                                and: state.transactionStatus)

                    state.displayState.currentAsset = asset.info
                    state.displayState.isFavorite = asset.info.isFavorite
                    state.displayState.isDisabledFavoriteButton = asset.info.isSpam || asset.info.isWaves
                    state.displayState.isUserInteractionEnabled = true
                    state.displayState.action = .refresh
                } else {
                    state.transactionStatus = .none
                    state.displayState.sections = []
                    state.displayState.action = .none
                }
                state.displayState.isRefreshing = false
                state.displayState.assets = assets.map { $0.info }
                state.assets = assets
            }

        case .tapFavorite(let on):

            interactor.toggleFavoriteFlagForAsset(by: state.displayState.currentAsset.id, isFavorite: on)

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

// MARK: Map
extension AssetPresenter {

    func mapTosections(from asset: AssetTypes.DTO.Asset,
                             and transactionStatus: AssetTypes.State.TransactionStatus) -> [AssetTypes.ViewModel.Section]
    {

        let balance: AssetTypes.ViewModel.Section = .init(kind: .none, rows: [.balance(asset.balance)])
        let assetInfo: AssetTypes.ViewModel.Section =   .init(kind: .none, rows: [.assetInfo(asset.info)])

        var transactionRows: [AssetTypes.ViewModel.Row] = []
        var transactionHeaderTitle: String = ""

        switch transactionStatus {
        case .empty:
            transactionHeaderTitle = Localizable.Asset.Header.notHaveTransactions
            transactionRows = [.viewHistoryDisabled]

        case .loading:
            transactionHeaderTitle = Localizable.Asset.Header.lastTransactions
            transactionRows = [.transactionSkeleton]

        case .transaction(let transactions):
            transactionHeaderTitle = Localizable.Asset.Header.lastTransactions
            transactionRows = [.lastTransactions(transactions), .viewHistory]

        case .none:
            break
        }

        let transactions: AssetTypes.ViewModel.Section = .init(kind: .title(transactionHeaderTitle),
                                                               rows: transactionRows)

        return [balance,
                transactions,
                assetInfo]

    }
}

// MARK: UI State

private extension AssetPresenter {

    func initialState(input: AssetModuleInput) -> AssetTypes.State {
        return AssetTypes.State(assets: [],
                                transactionStatus: .none,
                                displayState: initialDisplayState(input: input))
    }

    func initialDisplayState(input: AssetModuleInput) -> AssetTypes.DisplayState {

        let balances = AssetTypes.ViewModel.Section.init(kind: .none, rows: [.balanceSkeleton])
        let transactions = AssetTypes.ViewModel.Section.init(kind: .skeletonTitle, rows: [.transactionSkeleton, .viewHistorySkeleton])

        return AssetTypes.DisplayState(isAppeared: false,
                                       isRefreshing: false,
                                       isFavorite: false,
                                       isDisabledFavoriteButton: false,
                                       isUserInteractionEnabled: false,
                                       currentAsset: input.currentAsset,
                                       assets: input.assets,
                                       sections: [balances,
                                                  transactions],
                                       action: .refresh)
    }
}
