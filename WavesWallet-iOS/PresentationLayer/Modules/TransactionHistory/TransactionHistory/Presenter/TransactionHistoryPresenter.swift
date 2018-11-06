//
//  TransactionHistoryPresenter.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol TransactionHistoryPresenterProtocol {
    typealias Feedback = (Driver<TransactionHistoryTypes.State>) -> Signal<TransactionHistoryTypes.Event>
    
    func system(feedbacks: [Feedback])
}

final class TransactionHistoryPresenter: TransactionHistoryPresenterProtocol {
    
    var interactor: TransactionHistoryInteractorProtocol!
    weak var moduleOutput: TransactionHistoryModuleOutput?
    let moduleInput: TransactionHistoryModuleInput
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(input: TransactionHistoryModuleInput) {
        moduleInput = input
    }
    
    func system(feedbacks: [TransactionHistoryPresenterProtocol.Feedback]) {
        
        let newFeedbacks = feedbacks
        
        Driver.system(initialState: TransactionHistoryPresenter.initialState(transactions: moduleInput.transactions, currentIndex: moduleInput.currentIndex), reduce: reduce, feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func reduce(state: TransactionHistoryTypes.State, event: TransactionHistoryTypes.Event) -> TransactionHistoryTypes.State {
        switch event {
        case .readyView:
            return state
        }
    }
    
    private static func initialState(transactions: [DomainLayer.DTO.SmartTransaction], currentIndex: Int) -> TransactionHistoryTypes.State {
        return TransactionHistoryTypes.State.initialState(transactions: transactions, currentIndex: currentIndex)
    }
    
}
