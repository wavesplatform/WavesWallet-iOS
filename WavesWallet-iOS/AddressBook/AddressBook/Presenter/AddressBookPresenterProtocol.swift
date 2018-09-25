//
//  AddressBookPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol AddressBookPresenterProtocol {
    typealias Feedback = (Driver<AddressBookTypes.State>) -> Signal<AddressBookTypes.Event>
    var interactor: AddressBookInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
