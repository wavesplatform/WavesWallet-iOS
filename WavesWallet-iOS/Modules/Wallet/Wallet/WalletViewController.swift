//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxCocoa
import RxFeedback
import RxSwift
import UIKit
import Extensions
import DomainLayer

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

final class WalletViewController: UIViewController {

    @IBOutlet weak var scrolledTablesComponent: ScrolledContainerView!
    @IBOutlet var globalErrorView: GlobalErrorView!

    private var displayData: WalletDisplayData!

    private let disposeBag: DisposeBag = DisposeBag()
    private let displays: [WalletTypes.DisplayState.Kind] = [.assets, .leasing]

    private var isRefreshing: Bool = false
    private var snackError: String? = nil
    private var hasAddingViewBanners: Bool = false
    
    private let buttonAddress = UIBarButtonItem(image: Images.walletScanner.image,
                                                style: .plain,
                                                target: nil,
                                                action: nil)
    private let buttonSort = UIBarButtonItem(image: Images.walletSort.image,
                                             style: .plain,
                                             target: nil,
                                             action: nil)

    private let sendEvent: PublishRelay<WalletTypes.Event> = PublishRelay<WalletTypes.Event>()

    var presenter: WalletPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayData = WalletDisplayData(scrolledTablesComponent: scrolledTablesComponent)
        
        scrolledTablesComponent.scrollViewDelegate = self
        scrolledTablesComponent.containerViewDelegate = self
        scrolledTablesComponent.setup(segmentedItems: displays.map{ $0.name }, tableDataSource: displayData, tableDelegate: displayData)

        setupLanguages()
        setupBigNavigationBar()
        createMenuButton()
        setupSegmetedControl()
        setupTableView()
        setupSystem()
        
        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
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
            }
            else if let clearView = view as? WalletClearAssetsView {
                clearView.update(with: ())
            }
        }
        scrolledTablesComponent.reloadData()
    }
}

//MARK: - MainTabBarControllerProtocol
extension WalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        scrolledTablesComponent.scrollToTop()
    }
}

//MARK: - UIScrollViewDelegate
extension WalletViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrolledTablesComponent {
            setupSearchBarOffset()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == scrolledTablesComponent {
            setupSearchBarOffset()
        }
    }
}

//MARK: - ScrolledContainerViewDelegate
extension WalletViewController: ScrolledContainerViewDelegate {
    
    func scrolledContainerViewDidScrollToIndex(_ index: Int) {
        setupRightButons(kind: displays[index])
        sendEvent.accept(.changeDisplay(displays[index]))
        
        DispatchQueue.main.async {
            self.scrolledTablesComponent.endRefreshing()
        }
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
                changedSpamList]
    }


    func subscriptions(state: Driver<WalletTypes.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }
            if state.action == .none {
                return
            }
            
            self.addTopViewBanners(hasData: state.hasData,
                                   isShowCleanWalletBanner: state.isShowCleanWalletBanner,
                                   isHasAppUpdate: state.isHasAppUpdate)
            
            self.updateView(with: state.displayState)
        })
        
        return [subscriptionSections]
    }

    func addTopViewBanners(hasData: Bool, isShowCleanWalletBanner: Bool, isHasAppUpdate: Bool) {
        if hasData && !hasAddingViewBanners {
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

        displayData.apply(assetsSections: state.assets.visibleSections, leasingSections: state.leasing.visibleSections, animateType: state.animateType) { [weak self] in
                            
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
        scrolledTablesComponent.segmentedControl.setSelectedIndex(displays.firstIndex(of: state.kind) ?? 0, animation: false)
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

            case .message(let message):
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

    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
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

    func setupSearchBarOffset() {
        
        if isSmallNavigationBar && displayData.isNeedSetupSearchBarPosition {
            
            let diff = (scrolledTablesComponent.topOffset + WalletSearchTableViewCell.viewHeight()) - (scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset)
            
            var offset: CGFloat = 0
            if diff > WalletSearchTableViewCell.viewHeight() / 2 {
                offset = -scrolledTablesComponent.smallTopOffset
            }
            else {
                offset = -scrolledTablesComponent.smallTopOffset + WalletSearchTableViewCell.viewHeight()
            }
            offset += scrolledTablesComponent.topOffset
            setupSmallNavigationBar()
            
            scrolledTablesComponent.setContentOffset(.init(x: 0, y: offset), animated: true)
        }
    }

    
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

    func setupTableView() {
        displayData.delegate = self
        displayData.balanceCellDelegate = self
    }

    func setupSegmetedControl() {
        scrolledTablesComponent.segmentedControl.items = displays.map{ $0.name }
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

    
    func showSearchVC(fromStartPosition: CGFloat) {
                
        sendEvent.accept(.presentSearch(startPoint: fromStartPosition))
    }
    
    func tableViewDidSelect(indexPath: IndexPath) {
        sendEvent.accept(.tapRow(indexPath))
    }
}
