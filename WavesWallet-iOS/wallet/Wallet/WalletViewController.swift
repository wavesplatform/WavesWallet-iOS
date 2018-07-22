//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RESideMenu
import RxCocoa
import RxDataSources
import RxFeedback
import RxSwift
import UIKit

final class WalletViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: WalletSegmentedControl!
    var refreshControl: UIRefreshControl!

    private var presenter: WalletPresenterProtocol = WalletPresenter()
    private let displayData: WalletDisplayData = WalletDisplayData()
    private let disposeBag: DisposeBag = DisposeBag()

    private let displays: [WalletTypes.Display] = [.assets, .leasing]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet"

        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        tableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 16, 0)
        navigationController?.navigationBar.barTintColor = UIColor.basic50

        displayData.delegate = self
        setupSegmetedControl()
        createMenuButton()
        setupRightButons()
        setupTopBarLine()

        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        let readyViewEvent = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapTo(())
            .take(1)
            .map { WalletTypes.Event.readyView }
            .asSignal(onErrorSignalWith: Signal.empty())

        let refreshEvent = refreshControl
            .rx
            .controlEvent(.valueChanged)
            .map { WalletTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tapEvent = displayData
            .tapSection
            .map { WalletTypes.Event.tapSection($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedDisplayEvent = segmentedControl.changedValue()
            .map { [weak self] selectedIndex -> WalletTypes.Event in

                let display = self?.displays[selectedIndex] ?? .assets
                return .changeDisplay(display)
            }

        let feedback: WalletPresenterProtocol.Feedback = bind(self) { owner, state in

            let refreshState = state
                .filter { $0.animateType.isRefresh }
                .map { $0.visibleSections }

            let collapsedSection = state
                .filter { $0.animateType.isCollapsed }
                .map { (sections: $0.visibleSections,
                        index: $0.animateType.sectionIndex ?? 0) }

            let expandedSection = state
                .filter { $0.animateType.isExpanded }
                .map { (sections: $0.visibleSections,
                        index: $0.animateType.sectionIndex ?? 0) } 
            
            owner.displayData.bind(tableView: owner.tableView, event: refreshState)
            owner.displayData.collapsed(tableView: owner.tableView, event: collapsedSection)
            owner.displayData.expanded(tableView: owner.tableView, event: expandedSection)            
            let subscriptionRefreshControl = state.map { $0.isRefreshing }
                .drive(owner.refreshControl.rx.isRefreshing)

            let subscriptions: [Disposable] = [subscriptionRefreshControl]

            let events: [Signal<WalletTypes.Event>] = [readyViewEvent,
                                                       refreshEvent,
                                                       tapEvent,
                                                       changedDisplayEvent]

            return Bindings(subscriptions: subscriptions,
                            events: events)
        }

        presenter.bindUI(feedback: feedback)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTopBarLine()
        setupBigNavigationBar()

        navigationController?.setNavigationBarHidden(false, animated: true)
        if rdv_tabBarController.isTabBarHidden {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }

    func setupRightButons() {
//        if selectedSegmentIndex == .assets {
//            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"), style: .plain, target: self, action: #selector(scanTapped))
//            let btnSort = UIBarButtonItem(image: UIImage(named: "wallet_sort"), style: .plain, target: self, action: #selector(sortTapped))
//            navigationItem.rightBarButtonItems = [btnScan, btnSort]
//        }
//        else {
//            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"), style: .plain, target: self, action: #selector(scanTapped))
//            navigationItem.rightBarButtonItems = [btnScan]
//        }
    }

    func setupSegmetedControl() {
        segmentedControl
            .segmentedControl
            .update(with: [SegmentedControl.Button(name: "Assets"),
                           SegmentedControl.Button(name: "Leasing")],
                    animated: true)
    }
}

// MARK: WalletDisplayDataDelegate
extension WalletViewController: WalletDisplayDataDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//    @objc func beginRefresh() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.refreshControl.endRefreshing()
//        }
//    }
//
//    @objc func setupLastScrollCorrectOffset() {
//        lastScrollCorrectOffset = tableView.contentOffset
//    }
//
//    @objc func startLeasing() {
//        setupLastScrollCorrectOffset()
//        let sort = storyboard?.instantiateViewController(withIdentifier: "StartLeasingViewController") as! StartLeasingViewController
//        navigationController?.pushViewController(sort, animated: true)
//
//        rdv_tabBarController.setTabBarHidden(true, animated: true)
//    }
//
//    @objc func scanTapped() {
//
//        let controller = storyboard?.instantiateViewController(withIdentifier: "MyAddressViewController") as! MyAddressViewController
//        navigationController?.pushViewController(controller, animated: true)
//    }
//
//    @objc func sortTapped() {
//
//        setupLastScrollCorrectOffset()
//        let sort = storyboard?.instantiateViewController(withIdentifier: "WalletSortViewController") as! WalletSortViewController
//        navigationController?.pushViewController(sort, animated: true)
//
//        rdv_tabBarController.setTabBarHidden(true, animated: true)
//    }
//
//    @objc func headerTapped(_ sender: UIButton) {
//
//        let section = sender.tag
//
//        if selectedSegmentIndex == .assets {
//
//            if section == SectionAssets.hidden.rawValue {
//                if assetsHiddenItems.count == 0 {
//                    return
//                }
//
//                isOpenHiddenAssets = !isOpenHiddenAssets
//
//                tableView.beginUpdates()
//                tableView.reloadSections([section], animationStyle: .fade)
//                tableView.endUpdates()
//
//                if isOpenHiddenAssets {
//                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
//                }
//
//                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
//                    view.setupArrow(isOpenHideenAsset: isOpenHiddenAssets, animation: true)
//                }
//            }
//            else if section == SectionAssets.spam.rawValue {
//                if assetsSpamItems.count == 0 {
//                    return
//                }
//
//                isOpenSpamAssets = !isOpenSpamAssets
//
//                tableView.beginUpdates()
//                tableView.reloadSections([section], animationStyle: .fade)
//                tableView.endUpdates()
//
//                if isOpenSpamAssets {
//                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
//                }
//
//                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
//                    view.setupArrow(isOpenHideenAsset: isOpenSpamAssets, animation: true)
//                }
//            }
//
//        }
//        else {
//            if section == SectionLeasing.active.rawValue {
//                if leasingActiveItems.count == 0 {
//                    return
//                }
//
//                isOpenActiveLeasing = !isOpenActiveLeasing
//
//                tableView.beginUpdates()
//                tableView.reloadSections([section], animationStyle: .fade)
//                tableView.endUpdates()
//
//                if isOpenActiveLeasing {
//                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
//                }
//
//                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
//                    view.setupArrow(isOpenHideenAsset: isOpenActiveLeasing, animation: true)
//                }
//            }
//            else if section == SectionLeasing.quickNote.rawValue {
//                isOpenQuickNote = !isOpenQuickNote
//
//                tableView.beginUpdates()
//                tableView.reloadSections([section], animationStyle: .fade)
//                tableView.endUpdates()
//
//                if isOpenQuickNote {
//                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
//                }
//
//                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
//                    view.setupArrow(isOpenHideenAsset: isOpenQuickNote, animation: true)
//                }
//            }
//
//        }
//    }
//

//
//    func walletTopTableCellDidChangeIndex(_ index: WalletSelectedIndex) {
//
//        hasFirstChangeSegment = true
//        setupTableSections(index)
//    }
//
//
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
//
// }
