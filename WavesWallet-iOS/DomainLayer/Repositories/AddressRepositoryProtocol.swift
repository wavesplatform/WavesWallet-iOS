//
//  AddressRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 20/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

//https://raw.githubusercontent.com/wavesplatform/waves-client-config/master/fee.json

protocol AddressRepositoryProtocol {

    func isSmartAddress(address: String) -> Observable<Bool>
}
