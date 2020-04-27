//
//  MyOrdersSystem.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 23.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import WavesSDK

final class MyOrdersSystem: System<MyOrdersTypes.State, MyOrdersTypes.Event> {
    private let repository = UseCasesFactory.instance.repositories.dexOrderBookRepository
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

    override func initialState() -> MyOrdersTypes.State! {
        let skeletonRows: [MyOrdersTypes.ViewModel.Row] = [.skeleton, .skeleton, .skeleton, .skeleton, .skeleton]

        return MyOrdersTypes.State(uiAction: .update,
                                   coreAction: .none,
                                   section: .init(allItems: skeletonRows,
                                                  activeItems: skeletonRows,
                                                  closedItems: skeletonRows,
                                                  canceledItems: skeletonRows),
                                   orders: [])
    }

    override func internalFeedbacks() -> [Feedback] {
        return [myOrdersQuery(), cancelAllOrdersQuery(), cancelOrderQuery()]
    }

    override func reduce(event: MyOrdersTypes.Event, state: inout MyOrdersTypes.State) {
        switch event {
        case .readyView:
            state.coreAction = .loadOrders
            state.uiAction = .none

        case .refresh:
            state.coreAction = .loadOrders
            state.uiAction = .none

        case let .setOrders(orders):
            state.orders = orders

            state.section.allItems = orders.map { $0.rowModel }
            if state.section.allItems.isEmpty {
                state.section.allItems = [.emptyData]
            }

            state.section.activeItems = orders.filter { $0.isActive }.map { $0.rowModel }
            if state.section.activeItems.isEmpty {
                state.section.activeItems = [.emptyData]
            }

            state.section.closedItems = orders.filter { $0.status == .filled }.map { $0.rowModel }
            if state.section.closedItems.isEmpty {
                state.section.closedItems = [.emptyData]
            }

            state.section.canceledItems = orders.filter { $0.status == .cancelled }.map { $0.rowModel }
            if state.section.canceledItems.isEmpty {
                state.section.canceledItems = [.emptyData]
            }

            state.coreAction = .none
            state.uiAction = .update

        case .cancelAllOrders:
            state.coreAction = .cancelAllOrders
            state.uiAction = .none

        case .ordersDidFinishCancelSuccess:
            state.coreAction = .loadOrders
            state.uiAction = .ordersDidFinishCanceledSuccess(isMultipleOrders: true)

        case .orderDidFinishCancelSuccess:
            state.coreAction = .loadOrders
            state.uiAction = .ordersDidFinishCanceledSuccess(isMultipleOrders: false)

        case let .ordersDidFinishCancelError(error):
            state.coreAction = .none
            state.uiAction = .ordersDidFinishCanceledError(error)

        case let .cancelOrder(order):
            state.coreAction = .cancelOrder(orderId: order.id, amountAsset: order.amountAsset.id, priceAsset: order.priceAsset.id)
            state.uiAction = .none
        }
    }
}

private extension DomainLayer.DTO.Dex.MyOrder {
    var rowModel: MyOrdersTypes.ViewModel.Row {
        return MyOrdersTypes.ViewModel.Row.order(self)
    }
}

private extension MyOrdersSystem {
    func myOrdersQuery() -> Feedback {
        return react(request: { state -> MyOrdersTypes.State? in

            switch state.coreAction {
            case .loadOrders:
                return state

            default:
                return nil
            }
        }, effects: { [weak self] _ -> Signal<MyOrdersTypes.Event> in

            guard let self = self else { return Signal.empty() }

            return self.myOrders().map { .setOrders($0) }
                .asSignal { _ -> Signal<MyOrdersTypes.Event> in
                    Signal.just(.setOrders([]))
                }
        })
    }

    func cancelAllOrdersQuery() -> Feedback {
        return react(request: { state -> MyOrdersTypes.State? in

            switch state.coreAction {
            case .cancelAllOrders:
                return state

            default:
                return nil
            }
        }, effects: { [weak self] _ -> Signal<MyOrdersTypes.Event> in

            guard let self = self else { return Signal.empty() }

            return self.cancelAllOrders().map { _ in .ordersDidFinishCancelSuccess }
                .asSignal(onErrorRecover: { error -> Signal<MyOrdersTypes.Event> in

                    if let error = error as? NetworkError {
                        return Signal.just(.ordersDidFinishCancelError(error))
                    }
                    return Signal.just(.ordersDidFinishCancelError(NetworkError.error(by: error)))
                })
        })
    }

    func cancelOrderQuery() -> Feedback {
        return react(request: { state -> MyOrdersTypes.State? in

            switch state.coreAction {
            case .cancelOrder:
                return state

            default:
                return nil
            }
        }, effects: { [weak self] state -> Signal<MyOrdersTypes.Event> in

            guard let self = self else { return Signal.empty() }

            if case let .cancelOrder(orderId, amountAsset, priceAsset) = state.coreAction {
                return self.cancelOrder(orderId: orderId, amountAsset: amountAsset, priceAsset: priceAsset)
                    .map { _ in .orderDidFinishCancelSuccess }
                    .asSignal(onErrorRecover: { error -> Signal<MyOrdersTypes.Event> in

                        if let error = error as? NetworkError {
                            return Signal.just(.ordersDidFinishCancelError(error))
                        }
                        return Signal.just(.ordersDidFinishCancelError(NetworkError.error(by: error)))
                    })
            }
            return Signal.empty()

        })
    }
}

private extension MyOrdersSystem {
    func myOrders() -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(authorizationInteractor.authorizedWallet(),
                              serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                guard let self = self else { return Observable.empty() }
                return self.repository
                    .allMyOrders(serverEnvironment: serverEnvironment,
                                 wallet: wallet)
            }
    }

    func cancelAllOrders() -> Observable<Bool> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(authorizationInteractor.authorizedWallet(),
                              serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.repository.cancelAllOrders(serverEnvironment: serverEnvironment,
                                                       wallet: wallet)
            }
    }

    func cancelOrder(orderId: String,
                     amountAsset: String,
                     priceAsset: String) -> Observable<Bool> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(authorizationInteractor.authorizedWallet(),
                              serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.repository.cancelOrder(serverEnvironment: serverEnvironment,
                                                   wallet: wallet,
                                                   orderId: orderId,
                                                   amountAsset: amountAsset,
                                                   priceAsset: priceAsset)
            }
    }
}
