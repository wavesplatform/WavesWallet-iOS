//
//  ReceiveGenerateInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol ReceiveGenerateInteractorProtocol {
    
    func generateInvoiceAddress(_ info: ReceiveInvoive.DTO.GenerateInfo) -> Observable<Responce<ReceiveInvoive.DTO.DisplayInfo>>
}
