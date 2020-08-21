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

final class InvestmentViewController: UIViewController {
    @IBOutlet private weak var scrolledTablesComponent: ScrolledContainerView!
    @IBOutlet var globalErrorView: GlobalErrorView!

    private var displayData: InvestmentDisplayData!

    private let disposeBag = DisposeBag()
    private var displays: [InvestmentDisplayState.Kind] = [.staking, .leasing]

    private var isRefreshing: Bool = false
    private var snackError: String?
    private var hasAddingViewBanners: Bool = false

    private let sendEvent: PublishRelay<InvestmentEvent> = PublishRelay<InvestmentEvent>()

    var presenter: InvestmentPresenterProtocol!

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

        displayData = InvestmentDisplayData(scrolledTablesComponent: scrolledTablesComponent,
                                            displays: displays)

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
            if let updateView = view as? UpdateAppView {
                updateView.setupLocalization()
            }
        }
        scrolledTablesComponent.reloadData()
    }
    
    @objc private func didTapScannerItem() {
        sendEvent.accept(.didTapScannerItem)
    }
}

// MARK: - MainTabBarControllerProtocol

extension InvestmentViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        scrolledTablesComponent.scrollToTop()
    }
}

// MARK: - ScrolledContainerViewDelegate

extension InvestmentViewController: ScrolledContainerViewDelegate {
    func scrolledContainerViewDidScrollToIndex(_ index: Int) {
        setupButons()
        sendEvent.accept(.changeDisplay(displays[index]))

        DispatchQueue.main.async {
            self.scrolledTablesComponent.endRefreshing()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension InvestmentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool { true }
}

// MARK: Bind UI

extension InvestmentViewController {
    func setupSystem() {
        let feedback: InvestmentPresenterProtocol.Feedback = bind(self) { owner, state in

            let subscriptions = owner.subscriptions(state: state)
            let events = owner.events()

            return Bindings(subscriptions: subscriptions,
                            events: events)
        }

        let readyViewFeedback: InvestmentPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewWillAppear
                .map { _ in InvestmentEvent.viewWillAppear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        let viewDidDisappearFeedback: InvestmentPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewDidDisappear
                .map { _ in InvestmentEvent.viewDidDisappear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback,
                                     viewDidDisappearFeedback])
    }

    func events() -> [Signal<InvestmentEvent>] {
        let refreshEvent = scrolledTablesComponent
            .rx
            .didRefreshing(refreshControl: scrolledTablesComponent.refreshControl!)
            .map { _ in InvestmentEvent.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in InvestmentEvent.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tapEvent = displayData
            .tapSection
            .map { InvestmentEvent.tapSection($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let recieverEvents = sendEvent.asSignal()

        return [refreshEvent,
                tapEvent,
                recieverEvents,
                changedSpamList]
    }

    func subscriptions(state: Driver<InvestmentState>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }
            if state.action == .none {
                return
            }

            if state.action == .refreshError {
                self.updateErrorView(with: state.displayState.currentDisplay.errorState)
                return
            }

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: InvestmentDisplayState) {
        displayData.apply(leasingSections: state.leasing.visibleSections,
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
        setupButons()
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
                
            case .none: break

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

private extension InvestmentViewController {
    func setupLanguages() {
        navigationItem.title = Localizable.Waves.Investment.Navigationbar.title
    }

    func setupButons() {
        let buttonAddress = UIBarButtonItem(image: Images.walletScanner.image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapScannerItem))
        navigationItem.leftBarButtonItem = buttonAddress
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

// MARK: - InvestmentLeasingBalanceCellDelegate

extension InvestmentViewController: InvestmentLeasingBalanceCellDelegate {
    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money) {
        sendEvent.accept(.showStartLease(availableMoney))
    }
}

// MARK: WalletDisplayDataDelegate

extension InvestmentViewController: InvestmentDisplayDataDelegate {
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

    func tableViewDidSelect(indexPath: IndexPath) {
        sendEvent.accept(.tapRow(indexPath))
    }
}

// MARK: - DisplayStateKind

private extension InvestmentDisplayState.Kind {
    var segmentedItem: NewSegmentedControl.SegmentedItem {
        switch self {
        case .leasing:
            return .title(name)

        case .staking:
            return .ticker(.init(title: name, ticker: Localizable.Waves.Wallet.Segmentedcontrol.new.uppercased()))
        }
    }
}
