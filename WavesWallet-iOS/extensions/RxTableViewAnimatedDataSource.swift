//
//  RxTableViewAnimatedDataSource.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

final class RxTableViewAnimatedDataSource<S: Hashable>: TableViewSectionedDataSource<S>, RxTableViewDataSourceType where S: SectionModelType, S.Item: Hashable {
    typealias Element = [S]

    struct UpdateSection {
        let sections: Element
        let index: Int
    }

    private let disposeBag: DisposeBag = DisposeBag()

    var completedReload: (() -> Void)?
    var dataSet = false

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            
            if !self.dataSet && newSections.count > 0 {
                self.dataSet = true
                dataSource.setSections(newSections)
                tableView.reloadData()
            } else if self.dataSet {
                dataSource.setSections(newSections)
                UIView.transition(with: tableView,
                                  duration: 0.24,
                                  options: [.transitionCrossDissolve,
                                            .curveEaseInOut],
                                  animations: {
                                      tableView.reloadData()
                }, completion: { _ in
                    self.completedReload?()
                })
            }
        }
        .on(observedEvent)
    }

    func tableView(_ tableView: UITableView, reloadSection: Driver<UpdateSection>) {
        reloadSection.drive(onNext: { [weak self] update in

            self?.setSections(update.sections)
            tableView.reloadSections(IndexSet(integer: update.index), with: .fade)
        })
        .disposed(by: disposeBag)
    }
}
