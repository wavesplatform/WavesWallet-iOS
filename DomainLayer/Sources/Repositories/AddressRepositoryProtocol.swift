//
//  AddressRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 20/01/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol AddressRepositoryProtocol {

    func isSmartAddress(serverEnvironment: ServerEnvironment,
                        accountAddress: String) -> Observable<Bool>
}
