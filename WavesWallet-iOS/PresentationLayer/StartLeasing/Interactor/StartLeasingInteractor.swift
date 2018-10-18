//
//  StartLeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class StartLeasingInteractor: StartLeasingInteractorProtocol {
    
    func createOrder(order: StartLeasing.DTO.Order) -> Observable<(Response<Bool>)> {
        return Observable.empty()
    }
}
