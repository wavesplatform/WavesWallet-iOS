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

final class WalletViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var rootView: WalletView!

    @IBOutlet var globalErrorView: GlobalErrorView!

    private var displayData: WalletDisplayData!

    private let disposeBag: DisposeBag = DisposeBag()
    private var displays: [WalletDisplayState.Kind] = [.assets]

    private var isRefreshing: Bool = false
    private var snackError: String?

    private lazy var buttonAddress = UIBarButtonItem(image: Images.walletScanner.image,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(didTapButtonAddress))

    private lazy var buttonHistory = UIBarButtonItem(image: Images.history21122.image,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(didTapButtonHistory))

    private let sendEvent: PublishRelay<WalletEvent> = PublishRelay<WalletEvent>()
    private var state: WalletState?

    var presenter: WalletPresenterProtocol!

    weak var moduleOutput: WalletModuleOutput?

    public func refreshData() {
        sendEvent.accept(.refresh)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayData = WalletDisplayData(tableView: tableView,
                                        displays: displays)

        setupLanguages()
        setupBigNavigationBar()
        setupTableView()
        setupSystem()

        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }

        rootView.updateAppViewTapped = { [weak self] in
            self?.moduleOutput?.openAppStore()
        }

        rootView.walletSearchView.searchTapped = { [weak self] in

            guard let self = self else { return }
            guard let state = self.state else { return }

            // TODO: Remove Window (Old Code)
            let window = AppDelegate.shared().window
            let frame = self.rootView.walletSearchView.frame
            let fromStartPosition = self.view.convert(frame, to: window).origin.y

            self.moduleOutput?.presentSearchScreen(from: fromStartPosition, assets: state.assets)
        }

        rootView.walletSearchView.sortTapped = { [weak self] in
            guard let state = self?.state else { return }
            self?.moduleOutput?.showWalletSort(balances: state.assets)
        }

        rootView.smartBarView.sendButton.didTap = { [weak self] in
            self?.moduleOutput?.openSend()
        }

        rootView.smartBarView.receiveButton.didTap = { [weak self] in
            self?.moduleOutput?.openReceive()
        }

        rootView.smartBarView.cardButton.didTap = { [weak self] in
            self?.moduleOutput?.openCard()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changedLanguage),
                                               name: .changedLanguage,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeTopBarLine()
        tableView.startSkeletonCells()
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = nil
    }

    @objc private func changedLanguage() {
        setupLanguages()
        tableView.reloadData()
    }

    @objc private func didTapButtonAddress() {
        moduleOutput?.showMyAddress()
    }

    @objc private func didTapButtonHistory() {
        moduleOutput?.showAccountHistory()
    }
}

// MARK: - MainTabBarControllerProtocol

extension WalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        tableView.setContentOffset(.init(x: 0, y: -tableView.adjustedContentInset.top), animated: true)
    }
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
                .map { _ in WalletEvent.viewWillAppear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        let viewDidDisappearFeedback: WalletPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewDidDisappear
                .map { _ in WalletEvent.viewDidDisappear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback,
                                     viewDidDisappearFeedback])
    }

    func events() -> [Signal<WalletEvent>] {
        let refreshEvent = tableView
            .rx
            .didRefreshing(refreshControl: tableView.refreshControl!)
            .map { _ in WalletEvent.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tapEvent = displayData
            .tapSection
            .map { WalletEvent.tapSection($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in WalletEvent.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let recieverEvents = sendEvent.asSignal()

        return [refreshEvent,
                tapEvent,
                recieverEvents,
                changedSpamList]
    }

    func subscriptions(state: Driver<WalletState>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }

            self.state = state

            if state.action == .none {
                return
            }

            if state.action == .refreshError {
                self.updateErrorView(with: state.displayState.currentDisplay.errorState)
                return
            }

            if state.hasData, state.isHasAppUpdate {
                self.rootView.showAppStoreBanner()
            }

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: WalletDisplayState) {
        displayData.apply(assetsSections: state.assets.visibleSections,
                          animateType: state.animateType) { [weak self] in

            if self?.tableView.refreshControl?.isRefreshing == true {
                self?.tableView?.refreshControl?.endRefreshing()
            }
        }

        switch state.animateType {
        case .refreshOnlyError, .refresh:
            updateErrorView(with: state.currentDisplay.errorState)

        default:
            break
        }

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
    func setupLanguages() {
        navigationItem.title = Localizable.Waves.Wallet.Navigationbar.title
    }

    func setupButons(kind _: WalletDisplayState.Kind) {
        navigationItem.leftBarButtonItems = [buttonAddress]
        navigationItem.rightBarButtonItems = [buttonHistory]
    }

    func setupTableView() {
        displayData.delegate = self
        tableView.refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0,
                                                                  width: 30,
                                                                  height: 30))
    }
}

// MARK: WalletDisplayDataDelegate

extension WalletViewController: WalletDisplayDataDelegate {
    func tableViewDidSelect(indexPath: IndexPath) {
        guard let state = state else { return }

        let visibleSections = state.displayState.currentDisplay.visibleSections

        let section = visibleSections[indexPath.section]

        switch section.kind {
        case .hidden:
            guard let asset = section.items[indexPath.row].asset else { return }
            let assets = state.assets.filter { $0.settings.isHidden == true }
            moduleOutput?.showAsset(with: asset, assets: assets)

        case .spam:
            guard let asset = section.items[indexPath.row].asset else { return }
            let assets = state.assets.filter { $0.asset.isSpam == true }
            moduleOutput?.showAsset(with: asset, assets: assets)

        case .general:
            guard let asset = section.items[indexPath.row].asset else { return }
            let assets = state.assets.filter { $0.asset.isSpam != true && $0.settings.isHidden != true }
            moduleOutput?.showAsset(with: asset, assets: assets)

        default:
            break
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        rootView.scrollViewDidEndDecelerating(scrollView, viewController: self)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        rootView.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate, viewController: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rootView.scrollViewDidScroll(scrollView: scrollView, viewController: self)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        rootView.scrollViewWillBeginDragging(scrollView, viewController: self)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        rootView.scrollViewWillBeginDecelerating(scrollView, viewController: self)
    }
}

// MARK: - WalletTypes.DisplayState.Kind

private extension WalletDisplayState.Kind {
    var segmentedItem: NewSegmentedControl.SegmentedItem {
        switch self {
        case .assets:
            return .title(name)
        }
    }
}

private extension WalletDisplayState.Kind {
    var name: String {
        switch self {
        case .assets:
            return Localizable.Waves.Wallet.Segmentedcontrol.assets
        }
    }
}
