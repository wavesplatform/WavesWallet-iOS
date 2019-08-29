//
//  ConfirmRequestSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa
import Extensions
import WavesSDKExtensions
import WavesSDK

private typealias Types = ConfirmRequest

final class ConfirmRequestSystem: System<ConfirmRequest.State, ConfirmRequest.Event> {
    
    private lazy var widgetSettingsUseCase: WidgetSettingsUseCaseProtocol = UseCasesFactory.instance.widgetSettings
    
    private let input: ConfirmRequest.DTO.Input
    
    init(input: ConfirmRequest.DTO.Input) {
        self.input = input
    }
    
    override func initialState() -> State! {
        return ConfirmRequest.State(ui: uiState(),
                                    core: coreState())
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return []
    }
    
//    private lazy var deleteAsset: Feedback = {
//
//        return react(request: { (state) -> DomainLayer.DTO.Asset? in
//
//            if case .deleteAsset(let asset) = state.core.action {
//                return asset
//            }
//
//            return nil
//
//        }, effects: { [weak self] (asset) -> Signal<Event> in
//
//            guard let self = self else { return Signal.never() }
//
//            return self
//                .widgetSettingsUseCase
//                .removeAsset(asset)
//                .map { _ in Types.Event.none }
//                .asSignal(onErrorRecover: { _ in
//                    return Signal.empty()
//                })
//        })
//    }()
    

    override func reduce(event: Event, state: inout State) {
        
        switch event {
            
        case .none:
            break
            
        case .viewDidAppear:
            break
        }
    }
    
    private func uiState() -> State.UI! {
        return ConfirmRequest.State.UI(sections: sections(),
                                       action: .update)
    }
    
    private func coreState() -> State.Core! {
        return State.Core(action: .none)
    }
    
    private func sections() -> [Types.Section] {

        
        let kind = ConfirmRequestTransactionKindCell.Model.init(title: "Alalal",
                                                                image: UIImage(),
                                                                info: .descriptionLabel("Alalaba"))
        
        
        let fromTo = ConfirmRequestFromToCell.Model.init(address: "a232324234234",
                                                         dAppIcon: "asdasd",
                                                         dAppName: "alaxsam")
        
        let keyValue = ConfirmRequestKeyValueCell.Model.init(title: "alamr",
                                                             value: "213123")
        
        let balance = BalanceLabel.Model.init(balance: Balance.init(currency: .init(title: "233", ticker: "sd"),
                                                                    money: Money.init(0, 2)),
                                              sign: .minus,
                                              style: .large)
        
        let fee = ConfirmRequestFeeAndTimestampCell.Model.init(date: Date(), feeBalance: balance)
        
        let balancePay = ConfirmRequestBalanceCell.Model.init(title: "Payment", feeBalance: balance)
        
        
        let kindNew = ConfirmRequestTransactionKindCell.Model.init(title: "Alalal",
                                                                   image: Images.addaddress24Submit300.image,
                                                                   info: .balance(balance))
        
        let rows = [Types.Row.transactionKind(kind),
                    Types.Row.transactionKind(kindNew),
                    Types.Row.fromTo(fromTo),
                    Types.Row.keyValue(keyValue),
                    .feeAndTimestamp(fee),
                    .balance(balancePay),
                    .skeleton]
        
        return [Types.Section(rows: rows)]
    }
}
