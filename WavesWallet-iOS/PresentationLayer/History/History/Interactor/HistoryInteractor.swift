//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol HistoryInteractorProtocol {
    func transactions(input: HistoryModuleInput) -> AsyncObservable<[HistoryTypes.DTO.Transaction]>
    
    func refreshTransactions()
}

final class HistoryInteractorMock: HistoryInteractorProtocol {
    
    private let refreshTransactionsSubject: PublishSubject<[HistoryTypes.DTO.Transaction]> = PublishSubject<[HistoryTypes.DTO.Transaction]>()
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let replay: PublishSubject<Bool> = PublishSubject<Bool>()
    
    func transactions(input: HistoryModuleInput) -> Observable<[HistoryTypes.DTO.Transaction]> {
        return Observable.just([])
    }
    
    func refreshTransactions() {
        replay.onNext(true)
    }
    
}
