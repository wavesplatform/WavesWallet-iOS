//
//  RxTableViewAnimatedDataSource.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import DeepDiff
import Foundation
import RxCocoa
import RxDataSources
import RxSwift

final class RxTableViewAnimatedDataSource<S: Hashable>: TableViewSectionedDataSource<S>, RxTableViewDataSourceType where S: SectionModelType, S.Item: Hashable {
    typealias Element = [S]

    struct Configuration {
        let insert: UITableViewRowAnimation
        let delete: UITableViewRowAnimation
        let reload: UITableViewRowAnimation
    }

    private let disposeBag: DisposeBag = DisposeBag()

    var configuration: Configuration = Configuration(insert: .fade,
                                                     delete: .fade,
                                                     reload: .fade)
    var dataSet = false

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in

            if !self.dataSet && newSections.count > 0 {
                self.dataSet = true
                dataSource.setSections(newSections)
                tableView.reloadData()
            } else if self.dataSet {
                DispatchQueue.main.async {
                    // if view is not in view hierarchy, performing batch updates will crash the app
                    if tableView.window == nil {
                        dataSource.setSections(newSections)
                        tableView.reloadData()
                        return
                    }

                    dataSource.setSections(newSections)
                    UIView.transition(with: tableView, duration: 0.24, options: [.transitionCrossDissolve,
                                                                                 .preferredFramesPerSecond30,
                                                                                 .curveEaseInOut], animations: {
                            tableView.reloadData()
                        }, completion: { _ in

                    })
                }
            }
        }
        .on(observedEvent)
    }

    func tableView(_ tableView: UITableView, collapsedSectionEvent: Driver<(sections: Element, index: Int)>) {
        collapsedSectionEvent
            .drive(onNext: { data in

                let oldSections = self.sectionModels

                var newItems: [S.Item] = []
                var oldItems: [S.Item] = []

                if data.index < oldSections.count {
                    oldItems = oldSections[data.index].items
                }

                if data.index < data.sections.count {
                    newItems = data.sections[data.index].items
                }

//                let changes = diff(old: oldItems, new: newItems)
//                tableView.reload(changes: changes,
//                                 section: data.index,
//                                 insertionAnimation: .bottom,
//                                 deletionAnimation: .top,
//                                 replacementAnimation: .fade) { _ in }

                self.setSections(data.sections)
                tableView.reloadSections(IndexSet(integer: data.index), with: .fade)
            })
            .disposed(by: disposeBag)
    }

    func tableView(_ tableView: UITableView,
                   expandedSectionEvent: Driver<(sections: Element, index: Int)>) {
        expandedSectionEvent
            .drive(onNext: { data in

                let oldSections = self.sectionModels

                var newItems: [S.Item] = []
                var oldItems: [S.Item] = []

                if data.index < oldSections.count {
                    oldItems = oldSections[data.index].items
                }

                if data.index < data.sections.count {
                    newItems = data.sections[data.index].items
                }

                self.setSections(data.sections)
                tableView.reloadSections(IndexSet(integer: data.index), with: .fade)
            })
            .disposed(by: disposeBag)
    }
}
