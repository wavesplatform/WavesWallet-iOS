//
//  HistoryDisplayData.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol HistoryDisplayDataDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

final class HistoryDisplayData: NSObject {
    private typealias Section = HistoryTypes.ViewModel.Section
    var delegate: HistoryDisplayDataDelegate?
    
//    private lazy var configureCell: ConfigureCell<Section> = { _, tableView, _, item in
//        
//        switch item {
//        default:
//            return tableView.dequeueCell() as HistoryAssetCell
//        }
//        
//    }
//    
//    private lazy var dataSource = RxTableViewAnimatedDataSource(configureCell: configureCell)
//    
//    private var disposeBag: DisposeBag = DisposeBag()
//    
//    func bind(tableView: UITableView, event: Driver) {
//        tableView
//            .rx
//            .setDelegate(self)
//            .disposed(by: disposeBag)
//        
//        event
//            .drive(tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//    }
    
    
}
//
//// MARK: UITableViewDelegate
//
//extension HistoryDisplayData: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let row = dataSource[indexPath]
//        
//        switch row {
//        default:
//            return HistoryAssetCell.cellHeight()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.tableView(tableView, heightForRowAt: indexPath)
//    }
//    
//}
