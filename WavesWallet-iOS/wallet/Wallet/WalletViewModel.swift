//
//  WalletsViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class WalletViewModel {
    fileprivate typealias Section = WalletTypes.ViewModel.Section

    // MARK: Input

    var trigger: PublishRelay<Void> = PublishRelay<Void>()
    let tapAtSection: PublishRelay<Int> = PublishRelay<Int>()

    // MARK: Output

    var updateModels: Driver<[WalletTypes.ViewModel.Section]>

    private let disposeBug: DisposeBag = DisposeBag()
    private let interactor: WalletInteractorProtocol = WalletInteractor()
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()

    private var hiddenSections: [Bool] = [Bool]()
    private var sections: Variable<[Section]> = Variable<[Section]>([])

    init() {
        let asset = WalletTypes.ViewModel.Row.asset(WalletTypes.ViewModel.Asset(id: "",
                                                                                name: "test"))

        let section = WalletTypes.ViewModel.Section(id: "Test",
                                                    header: "Testing",
                                                    items: [asset, asset, asset, asset, asset],
                                                    isExpanded: true)

        let newSection = Observable<[Section]>.just([section])

        updateModels = accountBalanceInteractor
            .balanceBy(accountId: "3PCAB4sHXgvtu5NPoen6EXR5yaNbvsEA8Fj")
            .map { balanses -> [Section] in

                var rows = [WalletTypes.ViewModel.Row]()

                balanses.forEach { balance in
                    rows.append(.asset(.init(id: balance.assetId,
                                             name: balance.asset!.name)))
                }

                let section = WalletTypes.ViewModel.Section(id: "Test",
                                                            header: "Testing",
                                                            items: rows,
                                                            isExpanded: true)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])

//        updateModels = newSection.asDriver(onErrorJustReturn: [])
    }

    func bindViewModel() {}
}

protocol WalletInteractorProtocol {
    func assets() -> Observable<Void>
}

final class WalletInteractor: WalletInteractorProtocol {
    func assets() -> Observable<Void> {
        return Observable<Void>.never()
    }
}
