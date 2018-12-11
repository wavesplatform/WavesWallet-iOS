//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxFeedback
import RxSwift
import UIKit

private extension WalletTypes.DisplayState.Kind {

    var name: String {
        switch self {
        case .assets:
            return Localizable.Waves.Wallet.Segmentedcontrol.assets
        case .leasing:
            return Localizable.Waves.Wallet.Segmentedcontrol.leasing
        }
    }
}

private enum Constants {
    static let contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 16, right: 0)
}

final class WalletViewController: UIViewController {

    typealias Types = WalletTypes

    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: WalletSegmentedControl!
    @IBOutlet var globalErrorView: GlobalErrorView!

    private var refreshControl: UIRefreshControl!
    private var displayData: WalletDisplayData!

    private let disposeBag: DisposeBag = DisposeBag()
    private let displays: [WalletTypes.DisplayState.Kind] = [.assets, .leasing]

    private var isRefreshing: Bool = false
    private var snackError: String? = nil

    private let buttonAddress = UIBarButtonItem(image: Images.Wallet.walletScanner.image,
                                                style: .plain,
                                                target: nil,
                                                action: nil)
    private let buttonSort = UIBarButtonItem(image: Images.Wallet.walletSort.image,
                                             style: .plain,
                                             target: nil,
                                             action: nil)

    private let sendEvent: PublishRelay<WalletTypes.Event> = PublishRelay<WalletTypes.Event>()

    private lazy var leftRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerLeftSwipe(gesture:)))
    private lazy var rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerRightSwipe(gesture:)))
    var presenter: WalletPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        leftRightGesture.delegate = self
        leftRightGesture.direction = .left
        rightSwipeGesture.delegate = self
        rightSwipeGesture.direction = .right

        tableView.addGestureRecognizer(leftRightGesture)
        tableView.addGestureRecognizer(rightSwipeGesture)
        tableView.contentInset = Constants.contentInset
        
        displayData = WalletDisplayData(tableView: tableView)
        setupLanguages()
        setupBigNavigationBar()
        createMenuButton()
        setupSegmetedControl()
        setupTableView()
        setupRefreshControl()
        setupSystem()

        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }

    @objc func handlerLeftSwipe(gesture: UIGestureRecognizer) {

        if isHiddenSegmentedControl {
            return
        }
        sendEvent.accept(.changeDisplay(.leasing))
    }

    @objc func handlerRightSwipe(gesture: UIGestureRecognizer) {
        if isHiddenSegmentedControl {
            return
        }
        sendEvent.accept(.changeDisplay(.assets))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.startSkeletonCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }

    @objc func changedLanguage() {
        setupLanguages()
        setupSegmetedControl()
        tableView.reloadData()
    }

    private var isHiddenSegmentedControl: Bool {
        let frameSegmented = self.segmentedControl.convert(segmentedControl.frame, to: self.view)
        let barFrame = self.navigationController?.navigationBar.frame ?? CGRect.zero

        return barFrame.maxY > frameSegmented.maxY
    }
}

//MARK: - MainTabBarControllerProtocol
extension WalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        tableView.setContentOffset(tableViewTopOffsetForBigNavBar(tableView), animated: true)
    }
}

// MARK: UIGestureRecognizerDelegate

extension WalletViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear                
                .map { _ in WalletTypes.Event.viewWillAppear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        let viewDidDisappearFeedback: WalletPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
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

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in WalletTypes.Event.refresh }
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
                recieverEvents,
                changedSpamList]
    }


    func subscriptions(state: Driver<WalletTypes.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: WalletTypes.DisplayState) {

        displayData.apply(sections: state.visibleSections, animateType: state.animateType, completed: { [weak self] in
            if state.isRefreshing == false {            
                self?.refreshControl.endRefreshing()
            }
        })

        switch state.animateType {
        case .refreshOnlyError, .refresh:
                updateErrorView(with: state.currentDisplay.errorState)

        default:
            break
        }

        self.segmentedControl.segmentedControl.selectedIndex = displays.firstIndex(of: state.kind) ?? 0
        setupRightButons(kind: state.kind)
    }

    func updateErrorView(with state: DisplayErrorState) {

        switch state {
        case .none:
            if let snackError = snackError {
                hideSnack(key: snackError)
            }
            snackError = nil
            self.globalErrorView.isHidden = true

        case .error(let error):

            switch error {
            case .globalError(let isInternetNotWorking):
                self.globalErrorView.isHidden = false
                if isInternetNotWorking {
                    globalErrorView.update(with: .init(kind: .internetNotWorking))
                } else {
                    globalErrorView.update(with: .init(kind: .serverError))
                }

            case .internetNotWorking:
                globalErrorView.isHidden = true
                snackError = showWithoutInternetSnack()

            case .notFound:
                snackError = showErrorNotFoundSnack()

            case .message(let message):
                globalErrorView.isHidden = true
                snackError = showErrorSnack(message)
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

    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(tille: message, didTap: { [weak self] in
            self?.sendEvent.accept(.refresh)
        })
    }

    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack() { [weak self] in
            self?.sendEvent.accept(.refresh)
        }
    }
}

// MARK: Setup Methods

private extension WalletViewController {

    func setupLanguages() {
        navigationItem.title = Localizable.Waves.Wallet.Navigationbar.title
    }

    func setupRightButons(kind: WalletTypes.DisplayState.Kind) {

        switch kind {
        case .assets:
            navigationItem.rightBarButtonItems = [buttonAddress, buttonSort]

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
        displayData.balanceCellDelegate = self
    }

    func setupSegmetedControl() {
        let buttons = displays.map { SegmentedControl.Button(name: $0.name) }
        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
    }
}

//MARK: - WalletLeasingBalanceCellDelegate
extension WalletViewController: WalletLeasingBalanceCellDelegate {
    
    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money) {
        
        sendEvent.accept(.showStartLease(availableMoney))
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
