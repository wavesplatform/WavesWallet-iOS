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

private extension WalletTypes.DisplayState.Kind {

    var name: String {
        switch self {
        case .assets:
            return Localizable.Wallet.Segmentedcontrol.assets
        case .leasing:
            return Localizable.Wallet.Segmentedcontrol.leasing
        }
    }
}

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(0, 0, 16, 0)
}

final class WalletViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: WalletSegmentedControl!
    private var refreshControl: UIRefreshControl!

    private let disposeBag: DisposeBag = DisposeBag()
    private let displayData: WalletDisplayData = WalletDisplayData()
    private let displays: [WalletTypes.DisplayState.Kind] = [.assets, .leasing]

    //It flag need for fix bug "jump" UITableView when activate "refresh control'
    private var isRefreshing: Bool = false

    private let buttonAddress = UIBarButtonItem(image: Images.Wallet.walletScanner.image,
                                                style: .plain,
                                                target: nil,
                                                action: nil)
    private let buttonSort = UIBarButtonItem(image: Images.Wallet.walletSort.image,
                                             style: .plain,
                                             target: nil,
                                             action: nil)

    private let sendEvent: PublishRelay<WalletTypes.Event> = PublishRelay<WalletTypes.Event>()

    var presenter: WalletPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localizable.Wallet.Navigationbar.title
        setupBigNavigationBar()
        createMenuButton()
        setupSegmetedControl()
        setupTableView()
        setupRefreshControl()
        setupSystem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

extension WalletViewController {
    func setupSystem() {

        let feedback: WalletPresenterProtocol.Feedback = bind(self) { owner, state in

            let subscriptions = owner.uiSubscriptions(state: state.map { $0.displayState })
            let events = owner.events()

            return Bindings(subscriptions: subscriptions,
                            events: events)
        }

        let readyViewFeedback: WalletPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in WalletTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback,
                                    readyViewFeedback])
    }

    func events() -> [Signal<WalletTypes.Event>] {

        let sortTapEvent = buttonSort
            .rx
            .tap
            .map { WalletTypes.Event.tapSortButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        let addressTapEvent = buttonAddress
            .rx
            .tap
            .map { WalletTypes.Event.tapAddressButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        let refreshEvent = tableView
            .rx
            .didRefreshing(refreshControl: refreshControl)
            .map { _ in WalletTypes.Event.refresh }
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

        let recieverEvents = sendEvent.asSignal()

        return [refreshEvent,
                tapEvent,
                changedDisplayEvent,
                sortTapEvent,
                addressTapEvent,
                recieverEvents]
    }

    func uiSubscriptions(state: Driver<WalletTypes.DisplayState>) -> [Disposable] {

        let refreshState = state
            .filter { $0.currentDisplay.animateType.isRefresh }
            .map { $0.currentDisplay.visibleSections }

        let collapsedSection = state
            .filter { $0.currentDisplay.animateType.isCollapsed }
            .map { (sections: $0.visibleSections,
                    index: $0.animateType.sectionIndex ?? 0) }

        let expandedSection = state
            .filter { $0.currentDisplay.animateType.isExpanded }
            .map { (sections: $0.visibleSections,
                    index: $0.animateType.sectionIndex ?? 0) }

        displayData.bind(tableView: tableView, event: refreshState)
        displayData.collapsed(tableView: tableView, event: collapsedSection)
        displayData.expanded(tableView: tableView, event: expandedSection)

        let refreshControl = state
            .map { $0.currentDisplay.isRefreshing }
            .do(onNext: { [weak self] flag in
                guard let owner = self else { return }
                if flag {
                    if owner.isRefreshing == false {
                        owner.isRefreshing = true
                       owner.refreshControl.beginRefreshing()
                    }
                } else {
                    if owner.isRefreshing == true {
                        owner.isRefreshing = false
                        owner.displayData.completedReload = {
                            DispatchQueue.main.async {
                                owner.refreshControl.endRefreshing()
                            }
                        }
                    }
                }
            }).asObservable().subscribe()

        let segmentedControl = state
            .map { $0.kind }
            .drive(onNext: { [weak self] kind in
                self?.setupRightButons(kind: kind)
            })

        return [segmentedControl, refreshControl]
    }
}

// MARK: Setup Methods

private extension WalletViewController {
    func setupRightButons(kind: WalletTypes.DisplayState.Kind) {

        switch kind {
        case .assets:
            navigationItem.rightBarButtonItems = [buttonAddress,
                                                  buttonSort]

        case .leasing:
            navigationItem.rightBarButtonItems = [buttonAddress]
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
        displayData.delegate = self
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

    func tableViewDidSelect(indexPath: IndexPath) {
        sendEvent.accept(.tapRow(indexPath))
    }
}
