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
    func all(input: HistoryModuleInput) -> AsyncObservable<[HistoryTypes.DTO.Transaction]>
}

final class HistoryInteractorMock: HistoryInteractorProtocol {
    
//    .viewReceived,
//    .viewSend,
//    .viewLeasing,
//    .exchange, // not show comment, not show address
//    .selfTranserred, // not show address
//    .tokenGeneration, // show ID token
//    .tokenReissue, // show ID token,
//    .tokenBurning, // show ID token, do not have bottom state of token
//    .createdAlias, // show ID token
//    .canceledLeasing,
//    .incomingLeasing,
//    .massSend, // multiple addresses
//    .massReceived
    
    func all(input: HistoryModuleInput) -> Observable<[HistoryTypes.DTO.Transaction]> {
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
        
        return Observable.just([asset, asset1, asset2, asset3, asset4, asset5, asset6, asset6, asset7, asset8, asset9, asset10, asset11, asset12])
    }
    
}
