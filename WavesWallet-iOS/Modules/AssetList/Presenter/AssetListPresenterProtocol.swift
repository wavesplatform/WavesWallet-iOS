//
//  AssetListPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol AssetListPresenterProtocol {
    typealias Feedback = (Driver<AssetList.State>) -> Signal<AssetList.Event>
    var interactor: AssetListInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
    
    var moduleOutput: AssetListModuleOutput? { get set }
}
