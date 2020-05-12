//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxCocoa
import RxFeedback
import RxSwift
import UIKit
import UITools

private extension WalletTypes.DisplayState.Kind {
    var name: String {
        switch self {
        case .assets:
            return Localizable.Waves.Wallet.Segmentedcontrol.assets
        case .leasing:
            return Localizable.Waves.Wallet.Segmentedcontrol.leasing
        case .staking:
            return Localizable.Waves.Wallet.Segmentedcontrol.staking
        }
    }
}

// TODO: refactor all module
final class WalletViewController: UIViewController {
    @IBOutlet private weak var scrolledTablesComponent: ScrolledContainerView!
    @IBOutlet var globalErrorView: GlobalErrorView!

    private var displayData: WalletDisplayData!

    private let disposeBag: DisposeBag = DisposeBag()
    private var displays: [WalletTypes.DisplayState.Kind] = []

    private var isRefreshing: Bool = false
    private var snackError: String?
    private var hasAddingViewBanners: Bool = false

    private let buttonAddress = UIBarButtonItem(image: Images.walletScanner.image,
                                                style: .plain,
                                                target: nil,
                                                action: nil)
    private let buttonHistory = UIBarButtonItem(image: Images.history21122.image,
                                                style: .plain,
                                                target: nil,
                                                action: nil)

    private let buttonActionMenu = UIBarButtonItem(image: Images.sendReceive22.image,
                                                   style: .plain,
                                                   target: nil,
                                                   action: nil)

    private let sendEvent: PublishRelay<WalletTypes.Event> = PublishRelay<WalletTypes.Event>()

    var presenter: WalletPresenterProtocol!

    var isDisplayInvesting: Bool = false {
        didSet {
            if isDisplayInvesting {
                displays = [.staking, .leasing]
            } else {
                displays = [.assets]
            }
        }
    }

    public func completedDepositBalance(balance: DomainLayer.DTO.Balance) {
        sendEvent.accept(.completedDepositBalance(balance: balance))
    }

    public func completedWithdrawBalance(balance: DomainLayer.DTO.Balance) {
        sendEvent.accept(.completedWithdrawBalance(balance: balance))
    }

    public func refreshData() {
        sendEvent.accept(.refresh)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayData = WalletDisplayData(scrolledTablesComponent: scrolledTablesComponent,
                                        displays: displays)
        displayData.isDisplayInvesting = isDisplayInvesting

        scrolledTablesComponent.scrollViewDelegate = self
        scrolledTablesComponent.containerViewDelegate = self

        scrolledTablesComponent.setup(segmentedItems: displays.map { $0.segmentedItem },
                                      tableDataSource: displayData,
                                      tableDelegate: displayData)

        setupLanguages()
        setupBigNavigationBar()
        setupTableView()
        setupSystem()

        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeTopBarLine()
        for table in scrolledTablesComponent.tableViews {
            table.startSkeletonCells()
        }
        scrolledTablesComponent.viewControllerWillAppear()
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrolledTablesComponent.viewControllerWillDissapear()
        navigationController?.navigationBar.backgroundColor = nil
    }

    @objc func changedLanguage() {
        setupLanguages()
        setupSegmetedControl()

        for view in scrolledTablesComponent.topContents {
            if let updateView = view as? WalletUpdateAppView {
                updateView.update(with: ())
            } else if let clearView = view as? WalletClearAssetsView {
                clearView.update(with: ())
            }
        }
        scrolledTablesComponent.reloadData()
    }

    var isAssetDisplay: Bool {
        scrolledTablesComponent.visibleTableView.tag == WalletTypes.DisplayState.Kind.assets.rawValue
    }

    // TODO: Refactor method. I dont know how its work
    var isNeedSetupSearchBarPosition: Bool {
        return displayData.isAssetsSectionsHaveSearch && isAssetDisplay &&
            scrolledTablesComponent.contentSize.height > scrolledTablesComponent.frame.size.height &&
            scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset < scrolledTablesComponent
            .topOffset + WalletSearchTableViewCell.viewHeight() &&
            scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset > scrolledTablesComponent.topOffset
    }
}

// MARK: - MainTabBarControllerProtocol

extension WalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        scrolledTablesComponent.scrollToTop()
    }
}

// MARK: - UIScrollViewDelegate

extension WalletViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrolledTablesComponent {
            setupSearchBarOffset()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        if scrollView == scrolledTablesComponent {
            setupSearchBarOffset()
        }
    }
}

// MARK: - ScrolledContainerViewDelegate

extension WalletViewController: ScrolledContainerViewDelegate {
    func scrolledContainerViewDidScrollToIndex(_ index: Int) {
        setupButons(kind: displays[index])
        sendEvent.accept(.changeDisplay(displays[index]))

        DispatchQueue.main.async {
            self.scrolledTablesComponent.endRefreshing()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension WalletViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool { true }
}

// MARK: Bind UI

extension WalletViewController {
    func setupSystem() {
        let feedback: WalletPresenterProtocol.Feedback = bind(self) { owner, state in

            let subscriptions = owner.subscriptions(state: state)
            let events = owner.events()

            return Bindings(subscriptions: subscriptions,
                            events: events)
        }

        let readyViewFeedback: WalletPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewWillAppear
                .map { _ in WalletTypes.Event.viewWillAppear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        let viewDidDisappearFeedback: WalletPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewDidDisappear
                .map { _ in WalletTypes.Event.viewDidDisappear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback,
                                     viewDidDisappearFeedback])
    }

    func events() -> [Signal<WalletTypes.Event>] {
        let sortTapEvent = buttonHistory
            .rx
            .tap
            .map { WalletTypes.Event.tapHistory }
            .asSignal(onErrorSignalWith: Signal.empty())

        let addressTapEvent = buttonAddress
            .rx
            .tap
            .map { WalletTypes.Event.tapAddressButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        let actionMenuTapEvent = buttonActionMenu
            .rx
            .tap
            .map { WalletTypes.Event.tapActionMenuButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        let refreshEvent = scrolledTablesComponent
            .rx
            .didRefreshing(refreshControl: scrolledTablesComponent.refreshControl!)
            .map { _ in WalletTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tapEvent = displayData
            .tapSection
            .map { WalletTypes.Event.tapSection($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in WalletTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let recieverEvents = sendEvent.asSignal()

        return [refreshEvent,
                tapEvent,
                sortTapEvent,
                addressTapEvent,
                recieverEvents,
                changedSpamList,
                actionMenuTapEvent]
    }

    func subscriptions(state: Driver<WalletTypes.State>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }
            if state.action == .none {
                return
            }

            if state.action == .refreshError {
                self.updateErrorView(with: state.displayState.currentDisplay.errorState)
                return
            }

            self.addTopViewBanners(hasData: state.hasData,
                                   isShowCleanWalletBanner: state.isShowCleanWalletBanner,
                                   isHasAppUpdate: state.isHasAppUpdate)

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func addTopViewBanners(hasData: Bool,
                           isShowCleanWalletBanner: Bool,
                           isHasAppUpdate: Bool) {
        if hasData, !hasAddingViewBanners {
            hasAddingViewBanners = true
            if isHasAppUpdate {
                let view = WalletUpdateAppView.loadFromNib()
                scrolledTablesComponent.addTopView(view, animation: false)

                view.viewTapped = { [weak self] in
                    self?.sendEvent.accept(.updateApp)
                }
            }

            if isShowCleanWalletBanner {
                let view = WalletClearAssetsView.loadFromNib()
                scrolledTablesComponent.addTopView(view, animation: false)
                view.removeViewTapped = { [weak self] in
                    self?.scrolledTablesComponent.removeTopView(view, animation: true)
                    self?.sendEvent.accept(.setCleanWalletBanner)
                }
            }
        }
    }

    func updateView(with state: WalletTypes.DisplayState) {
        displayData.apply(assetsSections: state.assets.visibleSections,
                          leasingSections: state.leasing.visibleSections,
                          stakingSections: state.staking.visibleSections,
                          animateType: state.animateType) { [weak self] in

            if state.isRefreshing == false {
                self?.scrolledTablesComponent.endRefreshing()
            }
        }

        switch state.animateType {
        case .refreshOnlyError, .refresh:
            updateErrorView(with: state.currentDisplay.errorState)

        default:
            break
        }
        scrolledTablesComponent.setSelectedIndex(displays.firstIndex(of: state.kind) ?? 0,
                                                 animation: false)
        setupButons(kind: state.kind)
    }

    func updateErrorView(with state: DisplayErrorState) {
        switch state {
        case .none:
            if let snackError = snackError {
                hideSnack(key: snackError)
            }
            snackError = nil
            globalErrorView.isHidden = true

        case let .error(error):

            switch error {
            case let .globalError(isInternetNotWorking):
                globalErrorView.isHidden = false
                if isInternetNotWorking {
                    globalErrorView.update(with: .init(kind: .internetNotWorking))
                } else {
                    globalErrorView.update(with: .init(kind: .serverError))
                }

            case .internetNotWorking:
                globalErrorView.isHidden = true
                snackError = showWithoutInternetSnack()

            case let .message(message):
                globalErrorView.isHidden = true
                snackError = showErrorSnack(message)

            default:
                snackError = showErrorNotFoundSnack()
            }

        case .waiting:
            break
        }
    }

    private func showWithoutInternetSnack() -> String {
        return showWithoutInternetSnack { [weak self] in
            self?.sendEvent.accept(.refresh)
        }
    }

    private func showErrorSnack(_ message: String) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            self?.sendEvent.accept(.refresh)
        })
    }

    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack { [weak self] in
            self?.sendEvent.accept(.refresh)
        }
    }
}

// MARK: Setup Methods

private extension WalletViewController {
    func setupSearchBarOffset() {
        if isSmallNavigationBar, isNeedSetupSearchBarPosition {
            let diff = (scrolledTablesComponent.topOffset + WalletSearchTableViewCell.viewHeight()) -
                (scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset)

            var offset: CGFloat = 0
            if diff > WalletSearchTableViewCell.viewHeight() / 2 {
                offset = -scrolledTablesComponent.smallTopOffset
            } else {
                offset = -scrolledTablesComponent.smallTopOffset + WalletSearchTableViewCell.viewHeight()
            }
            offset += scrolledTablesComponent.topOffset
            setupSmallNavigationBar()

            scrolledTablesComponent.setContentOffset(.init(x: 0, y: offset), animated: true)
        }
    }

    func setupLanguages() {
        if isDisplayInvesting {
            navigationItem.title = Localizable.Waves.Investment.Navigationbar.title
        } else {
            navigationItem.title = Localizable.Waves.Wallet.Navigationbar.title
        }
    }

    func setupButons(kind _: WalletTypes.DisplayState.Kind) {
        navigationItem.leftBarButtonItems = [buttonAddress]
        navigationItem.rightBarButtonItems = [buttonHistory, buttonActionMenu]
    }

    func setupTableView() {
        displayData.delegate = self
        displayData.balanceCellDelegate = self
    }

    func setupSegmetedControl() {
        scrolledTablesComponent.setup(segmentedItems: displays.map { $0.segmentedItem },
                                      tableDataSource: displayData, tableDelegate: displayData)
    }
}

// MARK: - WalletLeasingBalanceCellDelegate

extension WalletViewController: WalletLeasingBalanceCellDelegate {
    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money) {
        sendEvent.accept(.showStartLease(availableMoney))
    }
}

// MARK: WalletDisplayDataDelegate

extension WalletViewController: WalletDisplayDataDelegate {
    func startStakingTapped() {
        sendEvent.accept(.startStaking)
    }

    func showPayout(payout _: PayoutTransactionVM) {}

    func openTw(_ sharedText: String) {
        sendEvent.accept(.openTw(sharedText))
    }

    func openFb(_ sharedText: String) {
        sendEvent.accept(.openFb(sharedText))
    }

    func openVk(_ sharedText: String) {
        sendEvent.accept(.openVk(sharedText))
    }

    func openStakingFaq(fromLanding: Bool) {
        sendEvent.accept(.openStakingFaq(fromLanding: fromLanding))
    }

    func withdrawTapped() {
        sendEvent.accept(.openWithdraw)
    }

    func depositTapped() {
        sendEvent.accept(.openDeposit)
    }

    func tradeTapped() {
        sendEvent.accept(.openTrade)
    }

    func buyTapped() {
        sendEvent.accept(.openBuy)
    }

    func showSearchVC(fromStartPosition: CGFloat) {
        sendEvent.accept(.presentSearch(startPoint: fromStartPosition))
    }

    func sortButtonTapped() {
        sendEvent.accept(.tapSortButton)
    }

    func tableViewDidSelect(indexPath: IndexPath) {
        sendEvent.accept(.tapRow(indexPath))
    }
}

// MARK: - WalletTypes.DisplayState.Kind

private extension WalletTypes.DisplayState.Kind {
    var segmentedItem: NewSegmentedControl.SegmentedItem {
        switch self {
        case .assets, .leasing:
            return .title(name)

        case .staking:
            return .ticker(.init(title: name, ticker: Localizable.Waves.Wallet.Segmentedcontrol.new.uppercased()))
        }
    }
}
