//
//  WalletsViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelProtocol {

    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

final class WalletViewModel: ViewModelProtocol {

    struct Input {}

    struct Output {
        var assets: Driver<[AssetViewModel]>
    }

    private let interactor: WalletInteractorProtocol = WalletInteractor()

    func transform(input: Input) -> Output {

        let assets = Driver<[AssetViewModel]>
            .just([AssetViewModel(name: "test",
                                 icon: UIImage(),
                                 balance: Money(10, 0),
                                 king: .gateway,
                                 state: .hidden)])


        return Output(assets: assets)
    }
}

protocol WalletInteractorProtocol {
    func assets() -> Observable<Void>
}

final class WalletInteractor: WalletInteractorProtocol {

    func assets() -> Observable<Void> {
        return Observable<Void>.never()
    }
}

let vm = WalletViewModel()


