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

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(0, 0, 16, 0)
}

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
        createMenuButton()
        setupRefreshControl()
        setupSegmetedControl()
        setupTableView()
        setupSystem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTopBarLine()
        setupBigNavigationBar()

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        if rdv_tabBarController.isTabBarHidden {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }
}

// MARK: Bind UI

private extension WalletViewController {

    func setupSystem() {

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

            let subscriptions: [Disposable] = owner.uiSubscriptions(state: state)

            let events: [Signal<WalletTypes.Event>] = [readyViewEvent,
                                                       refreshEvent,
                                                       tapEvent,
                                                       changedDisplayEvent]

            return Bindings(subscriptions: subscriptions,
                            events: events)
        }

        presenter.system(bindings: feedback)
    }

    func uiSubscriptions(state: Driver<WalletTypes.State>) -> [Disposable] {
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

        displayData.bind(tableView: tableView, event: refreshState)
        displayData.collapsed(tableView: tableView, event: collapsedSection)
        displayData.expanded(tableView: tableView, event: expandedSection)

        let refreshControl = state
            .map { $0.isRefreshing }
            .drive(self.refreshControl.rx.isRefreshing)

        let segmentedControl = state
            .map { $0.display }
            .drive(onNext: { [weak self] display in
                self?.setupRightButons(display: display)
            })

        return [refreshControl,
                segmentedControl]
    }
}

// MARK: Setup Methods

private extension WalletViewController {

    func setupRightButons(display: WalletTypes.Display) {

        switch display {
        case .assets:
            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"),
                                          style: .plain,
                                          target: nil, action: nil)
            let btnSort = UIBarButtonItem(image: UIImage(named: "wallet_sort"),
                                          style: .plain,
                                          target: nil, action: nil)
            navigationItem.rightBarButtonItems = [btnScan,
                                                  btnSort]
        case .leasing:
            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"),
                                          style: .plain,
                                          target: nil, action: nil)
            navigationItem.rightBarButtonItems = [btnScan]
        }
    }

    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    func setupTableView() {
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.contentInset = Constants.contentInset
        tableView.scrollIndicatorInsets = Constants.contentInset
        displayData.delegate = self

        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    func setupSegmetedControl() {

        let buttons = displays.map { SegmentedControl.Button(name: $0.name) }

        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
    }
}

// MARK: WalletDisplayDataDelegate

extension WalletViewController: WalletDisplayDataDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
