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

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output

    func bindViewModel(input: Input) -> Output
}

extension WalletTypes {
    enum Event {
        case loadedView
        case tappedAtSection(Int)
    }
}

final class WalletViewModel: ViewModelProtocol {
    fileprivate typealias Section = WalletTypes.ViewModel.Section

    struct Input {
        var trigger: Driver<Void>
        let tapAtSection: Driver<Int>
    }

    struct Output {
        var assets: Driver<[WalletTypes.ViewModel.Section]>
    }

    private var assets: Variable<[Section]> = Variable<[Section]>([])
    private var sections: [String: Bool] = [String: Bool]()

    private let disposeBug: DisposeBag = DisposeBag()

    private let interactor: WalletInteractorProtocol = WalletInteractor()

    func bindViewModel(input: Input) -> Output {

//        input
//            .event
//            .flatMap { event -> Observable<[Section]> in
//
//                switch event {
//                case .tappedAtSection, .loadedView:
//                    return self.assets(event: event)
//                }    
//            }
//            .bind(to: assets)
//            .disposed(by: disposeBug)


        return Output(assets: assets.asDriver())
    }

    private func assets(event: WalletTypes.Event) -> Observable<[Section]> {
        switch event {
        case .loadedView:

            let asset = WalletTypes.ViewModel.Row.asset(WalletTypes.ViewModel.Asset(id: "",
                                                                                    name: "test"))

            let section = WalletTypes.ViewModel.Section(id: "Test",
                                                        header: "Testing",
                                                        items: [asset, asset, asset, asset, asset],
                                                        isExpanded: true)


            return Observable<[Section]>.just([section])
        case .tappedAtSection(let section):
            var sections = assets.value
            var updateSection = sections[section]
            updateSection.isExpanded = !updateSection.isExpanded
            sections[section] = updateSection
            return Observable<[Section]>.just(sections)
        }
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
