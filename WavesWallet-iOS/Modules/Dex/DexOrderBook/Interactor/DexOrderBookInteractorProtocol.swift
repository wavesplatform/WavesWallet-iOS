//
//  DexOrderBookInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

protocol DexOrderBookInteractorProtocol {
    func displayInfo() -> Observable<DexOrderBook.DTO.DisplayData>
}
