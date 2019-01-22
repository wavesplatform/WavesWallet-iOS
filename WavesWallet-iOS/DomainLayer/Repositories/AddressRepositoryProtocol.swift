//
//  AddressRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 20/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AddressRepositoryProtocol {

    func isSmartAddress(accountAddress: String) -> Observable<Bool>
}
