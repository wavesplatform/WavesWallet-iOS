//
//  File.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

protocol WalletDisplayDataDelegate: AnyObject {

    func sectionDidSelect(section: Int, model: WalletTypes.ViewModel.Section)
}

final class AssetsDataSource: NSObject {
    private typealias Section = WalletTypes.ViewModel.Section

    weak var delegate: WalletDisplayDataDelegate?

    private lazy var configureCell: ConfigureCell<Section> = { _, tableView, _, item in

        let cell: WalletTableAssetsCell = tableView.dequeueCell()

        switch item {
        case .asset(let model):
            let cell: WalletTableAssetsCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell
        }

        //        cell.viewAssetType.isHidden = false
        //        cell.viewSpam.isHidden = true
        //        if indexPath.section == SectionAssets.main.rawValue {
        //            cell.setupCell(value: assetsMainItems[indexPath.row])
        //        }
        //        else if indexPath.section == SectionAssets.hidden.rawValue {
        //            cell.setupCell(value: assetsHiddenItems[indexPath.row])
        //        }
        //        else if indexPath.section == SectionAssets.spam.rawValue {
        //            cell.viewSpam.isHidden = false
        //            cell.viewAssetType.isHidden = true
        //            cell.setupCell(value: assetsSpamItems[indexPath.row])
        //        }

        return cell
    }

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(configureCell: configureCell)

    private var disposeBag: DisposeBag = DisposeBag()

    func bind(tableView: UITableView,
              data: Observable<[WalletTypes.ViewModel.Section]>) {
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        data
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDelegate

extension AssetsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = dataSource[section]

        if let header = model.header {
            let view: WalletHeaderView = tableView.dequeueAndRegisterHeaderFooter()
            view.update(with: header)
            view.setupArrow(isExpanded: model.isExpanded, animation: false)

            view.arrowDidTap = { [weak self] in
                self?.delegate?.sectionDidSelect(section: section, model: model)
            }
            return view
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let model = dataSource[section]
        if model.header != nil {
            return WalletHeaderView.viewHeight()
        }

        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletTableAssetsCell.cellHeight()
    }
}

//
//    func cellHeight(_ indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == SectionTop {
//            return WalletTopTableCell.cellHeight()
//        }
//
//        if selectedSegmentIndex == .assets {
//            if indexPath.section == SectionAssets.main.rawValue {
//                if indexPath.row == assetsMainItems.count - 1 {
//                    return WalletTableAssetsCell.cellHeight() + 10
//                }
//            }
//            else if indexPath.section == SectionAssets.hidden.rawValue {
//                if indexPath.row == assetsHiddenItems.count - 1 {
//                    return WalletTableAssetsCell.cellHeight() + 10
//                }
//            }
//            return WalletTableAssetsCell.cellHeight()
//        }
//
//        if indexPath.section == SectionLeasing.balance.rawValue {
//            if indexPath.row == 0 {
//                return WalletLeasingBalanceCell.cellHeight(isAvailableLeasingHistory: isAvailableLeasingHistory)
//            }
//            else if indexPath.row == 1 {
//                return WalletHistoryCell.cellHeight()
//            }
//        }
//        else if indexPath.section == SectionLeasing.active.rawValue {
//            if indexPath.row == leasingActiveItems.count - 1 {
//                return WalletLeasingCell.cellHeight() + 10
//            }
//            return WalletLeasingCell.cellHeight()
//        }
//        else if indexPath.section == SectionLeasing.quickNote.rawValue {
//            return WalletQuickNoteCell.cellHeight()
//        }
//
//        return 0
//    }
//

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView(tableView, heightForRowAt: indexPath)
//    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == SectionTop {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTopTableCell") as! WalletTopTableCell
//            cell.delegate = self
//            cell.setupState(selectedSegmentIndex, animation: false)
//            return cell
//        }
//
//        if selectedSegmentIndex == .leasing {
//            if indexPath.section == SectionLeasing.balance.rawValue {
//                if indexPath.row == 0 {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "WalletLeasingBalanceCell") as! WalletLeasingBalanceCell
//                    cell.setupCell(isAvailableLeasingHistory: isAvailableLeasingHistory)
//                    cell.buttonStartLease.addTarget(self, action: #selector(startLeasing), for: .touchUpInside)
//                    return cell
//                }
//                else if indexPath.row == 1 {
//                    var cell : WalletHistoryCell! = tableView.dequeueReusableCell(withIdentifier: "WalletHistoryCell") as? WalletHistoryCell
//                    if cell == nil {
//                        cell = WalletHistoryCell.loadView() as? WalletHistoryCell
//                    }
//                    return cell
//                }
//            }
//            else if indexPath.section == SectionLeasing.active.rawValue {
//
//                var cell : WalletLeasingCell! = tableView.dequeueReusableCell(withIdentifier: "WalletLeasingCell") as? WalletLeasingCell
//                if cell == nil {
//                    cell = WalletLeasingCell.loadView() as? WalletLeasingCell
//                }
//                cell.setupCell(leasingActiveItems[indexPath.row])
//                return cell
//            }
//            else if indexPath.section == SectionLeasing.quickNote.rawValue {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "WalletQuickNoteCell") as! WalletQuickNoteCell
//                return cell
//            }
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableAssetsCell") as! WalletTableAssetsCell
//        cell.viewAssetType.isHidden = false
//        cell.viewSpam.isHidden = true
//        if indexPath.section == SectionAssets.main.rawValue {
//            cell.setupCell(value: assetsMainItems[indexPath.row])
//        }
//        else if indexPath.section == SectionAssets.hidden.rawValue {
//            cell.setupCell(value: assetsHiddenItems[indexPath.row])
//        }
//        else if indexPath.section == SectionAssets.spam.rawValue {
//            cell.viewSpam.isHidden = false
//            cell.viewAssetType.isHidden = true
//            cell.setupCell(value: assetsSpamItems[indexPath.row])
//        }
//
//        return cell
//    }
// }
