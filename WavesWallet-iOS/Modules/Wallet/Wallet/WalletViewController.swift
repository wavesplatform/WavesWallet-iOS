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

final class WalletView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topLayoutConstraint: NSLayoutConstraint!

    private let walletSearchView = WalletSearchView.loadFromNib()

    private let smartBarView = SmartBarView()

    private var hasAddingViewBanners: Bool = false

    private var isSmartBarViewCollapsed: Bool = false

    var updateAppViewTapped: (() -> Void)?
    var sendViewTapped: (() -> Void)?
    var receiveViewTapped: (() -> Void)?
    var cardViewTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.addArrangedSubview(walletSearchView)
        stackView.addArrangedSubview(smartBarView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tableView.contentInset = .init(top: stackView.frame.height + 24, left: 0, bottom: 0, right: 0)
    }

    func showAppStoreBanner() {
        guard hasAddingViewBanners == false else { return }
        hasAddingViewBanners = true

        let view = UpdateAppView.loadFromNib()
        stackView.insertArrangedSubview(view, at: 0)

        view.viewTapped = { [weak self] in
            self?.updateAppViewTapped?()
//            self?.sendEvent.accept(.updateApp)
        }
    }

    private var lastContentOffset: CGFloat?

    func scrollViewDidScroll(scrollView: UIScrollView, navigationController _: UINavigationController?) {

        let value = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        var percent = value / smartBarView.maxHeighBeetwinImageAndDownSide()
        percent = min(1, percent)
        percent = max(0, percent)
        smartBarView.percent = percent

        print("percent scroll \(percent)")
        
        if value < 0 {
            topLayoutConstraint.constant = abs(value)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }

    func finish(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        var percent = value / smartBarView.maxHeighBeetwinImageAndDownSide()
        percent = min(1, percent)
        percent = max(0, percent)

        print("percent \(percent)")

        if percent > 0.45 {
            print("Close")
            smartBarView.close()
        } else {
            print("open")
            smartBarView.open()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        finish(scrollView)

        print("scrollViewDidEndDecelerating")
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
//        guard let lastContentOffset = lastContentOffset else {
//            return
//        }
//
//        let offSet = scrollView.contentOffset.y - lastContentOffset
//
        print("scrollViewDidEndDragging \(willDecelerate)")

        if willDecelerate {
            return
        }

        finish(scrollView)
    }
}

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

    private let sendEvent: PublishRelay<WalletEvent> = PublishRelay<WalletEvent>()

    var presenter: WalletPresenterProtocol!

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

    @objc func changedLanguage() {
        setupLanguages()
        tableView.reloadData()
    }
}

// MARK: - MainTabBarControllerProtocol

extension WalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        tableView.setContentOffset(.init(x: 0, y: tableView.contentInset.top), animated: true)
    }
}

// MARK: UIGestureRecognizerDelegate

// extension WalletViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool { true }
// }

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
        let sortTapEvent = buttonHistory
            .rx
            .tap
            .map { WalletEvent.tapHistory }
            .asSignal(onErrorSignalWith: Signal.empty())

        let addressTapEvent = buttonAddress
            .rx
            .tap
            .map { WalletEvent.tapAddressButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        let actionMenuTapEvent = buttonActionMenu
            .rx
            .tap
            .map { WalletEvent.tapActionMenuButton }
            .asSignal(onErrorSignalWith: Signal.empty())

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
                sortTapEvent,
                addressTapEvent,
                recieverEvents,
                changedSpamList,
                actionMenuTapEvent]
    }

    func subscriptions(state: Driver<WalletState>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }
            if state.action == .none {
                return
            }

            if state.action == .refreshError {
                self.updateErrorView(with: state.displayState.currentDisplay.errorState)
                return
            }

//            guard hasData else { return }
//            guard isHasAppUpdate else { return }

            if state.hasData, state.isHasAppUpdate {
                self.rootView.showAppStoreBanner()
            }

//            self.addTopViewBanners(hasData: state.hasData,
//                                   isHasAppUpdate: state.isHasAppUpdate)

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
        navigationItem.rightBarButtonItems = [buttonHistory, buttonActionMenu]
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
    func showSearchVC(fromStartPosition: CGFloat) {
        sendEvent.accept(.presentSearch(startPoint: fromStartPosition))
    }

    func sortButtonTapped() {
        sendEvent.accept(.tapSortButton)
    }

    func tableViewDidSelect(indexPath: IndexPath) {
        sendEvent.accept(.tapRow(indexPath))
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        rootView.scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        rootView.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rootView.scrollViewDidScroll(scrollView: scrollView, navigationController: navigationController)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        rootView.scrollViewWillBeginDragging(scrollView)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        rootView.scrollViewWillBeginDecelerating(scrollView)
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
