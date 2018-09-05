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
<<<<<<< HEAD
        
        let asset = HistoryTypes.DTO.Transaction(id: "0", name: "Waves", balance: Money(100, 1), kind: .viewReceived, tag: "Waves", date: NSDate(), sortLevel: 0)
        let asset1 = HistoryTypes.DTO.Transaction(id: "1", name: "Waves", balance: Money(100, 1), kind: .viewSend, tag: "Waves", date: NSDate(), sortLevel: 0)
        let asset2 = HistoryTypes.DTO.Transaction(id: "2", name: "BTC", balance: Money(100, 1), kind: .viewLeasing, tag: "BTC TAG", date: NSDate(), sortLevel: 0)
        let asset3 = HistoryTypes.DTO.Transaction(id: "3", name: "COIN", balance: Money(100, 1), kind: .exchange, tag: "COIN", date: NSDate(), sortLevel: 0)
        let asset4 = HistoryTypes.DTO.Transaction(id: "4", name: "SOME", balance: Money(100, 1), kind: .selfTranserred, tag: "SOME", date: NSDate(), sortLevel: 0)
        let asset5 = HistoryTypes.DTO.Transaction(id: "5", name: "Waves", balance: Money(100, 1), kind: .tokenGeneration, tag: "Waves", date: NSDate(), sortLevel: 0)
        let asset6 = HistoryTypes.DTO.Transaction(id: "6", name: "Dollar", balance: Money(100, 1), kind: .tokenReissue, tag: "Dollar", date: NSDate(), sortLevel: 0)
        let asset7 = HistoryTypes.DTO.Transaction(id: "7", name: "Dollar", balance: Money(100, 1), kind: .tokenBurning, tag: "Dollar", date: NSDate(), sortLevel: 0)
        let asset8 = HistoryTypes.DTO.Transaction(id: "8", name: "Euro", balance: Money(100, 1), kind: .createdAlias, tag: "Euro", date: NSDate(), sortLevel: 0)
        let asset9 = HistoryTypes.DTO.Transaction(id: "9", name: "Waves", balance: Money(100, 1), kind: .canceledLeasing, tag: "Waves", date: NSDate(), sortLevel: 0)
        let asset10 = HistoryTypes.DTO.Transaction(id: "10", name: "Waves", balance: Money(100, 1), kind: .incomingLeasing, tag: "Waves Tag", date: NSDate(), sortLevel: 0)
        let asset11 = HistoryTypes.DTO.Transaction(id: "11", name: "Waves", balance: Money(100, 1), kind: .massSend, tag: "Waves Tag", date: NSDate(), sortLevel: 0)
        let asset12 = HistoryTypes.DTO.Transaction(id: "12", name: "Waves", balance: Money(100, 1), kind: .massReceived, tag: "Waves Tag", date: NSDate(), sortLevel: 0)
        
        let transactions = Observable.just([asset, asset1, asset2, asset3, asset4, asset5, asset6, asset6, asset7, asset8, asset9, asset10, asset11, asset12])
        
        return Observable.merge(replay.flatMap { _ in transactions }, transactions).delay(5, scheduler: MainScheduler.asyncInstance)
=======
        let asset = HistoryTypes.DTO.Transaction(id: "0", name: "Waves", balance: Money(100, 1), kind: .viewReceived, tag: "Waves", date: NSDate(), sortLevel: 0)
        return Observable.just([asset])
>>>>>>> develop
    }
    
    func refreshTransactions() {
        replay.onNext(true)
    }
    
}
