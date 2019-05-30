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

final class NewWalletViewController: UIViewController {

    typealias Types = NewWalletTypes

    @IBOutlet weak var containerView: ScrolledContainerView!
    @IBOutlet var globalErrorView: GlobalErrorView!

    private let disposeBag: DisposeBag = DisposeBag()
    private let segmtentedItems: [NewWalletTypes.ViewModel.Kind] = [.assets, .leasing]

    private var isRefreshing: Bool = false
    private var snackError: String? = nil

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

    private var sections: [NewWalletTypes.ViewModel.Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.setup(segmentedItems: segmtentedItems.map{ $0.title },
                            topContents: [],
                            topContentsSectionIndex: 0,
                            tableDataSource: self,
                            tableDelegate: self)

        setupLanguages()
        setupBigNavigationBar()
        createMenuButton()
        setupSegmetedControl()
        setupTableView()
//        setupRefreshControl()
        setupSystem()
        hideTopBarLine()
        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.startSkeletonCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupTopBarLine()
    }

    @objc func changedLanguage() {
        setupLanguages()
        setupSegmetedControl()
//        tableView.reloadData()
    }
}

//MARK: - MainTabBarControllerProtocol
extension NewWalletViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
//        tableView.setContentOffset(tableViewTopOffsetForBigNavBar(tableView), animated: true)
    }
}

// MARK: Bind UI
extension NewWalletViewController {
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

//        let refreshEvent = tableView
//            .rx
//            .didRefreshing(refreshControl: refreshControl)
//            .map { _ in WalletTypes.Event.refresh }
//            .asSignal(onErrorSignalWith: Signal.empty())

//        let tapEvent = displayData
//            .tapSection
//            .map { WalletTypes.Event.tapSection($0) }
//            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in WalletTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

//        let changedDisplayEvent = segmentedControl.changedValue()
//            .map { [weak self] selectedIndex -> WalletTypes.Event in
//
//                let display = self?.displays[selectedIndex] ?? .assets
//                return .changeDisplay(display)
//            }

        let recieverEvents = sendEvent.asSignal()
        return [
//                tapEvent,
                sortTapEvent,
                addressTapEvent,
                recieverEvents,
                changedSpamList]

//        return [refreshEvent,
//                tapEvent,
//                changedDisplayEvent,
//                sortTapEvent,
//                addressTapEvent,
//                recieverEvents,
//                changedSpamList]
    }


    func subscriptions(state: Driver<WalletTypes.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }

//            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: WalletTypes.DisplayState) {

//        displayData.apply(sections: state.visibleSections, animateType: state.animateType, completed: { [weak self] in
//            if state.isRefreshing == false {
//                self?.refreshControl.endRefreshing()
//            }
//        })

        switch state.animateType {
        case .refreshOnlyError, .refresh:
                updateErrorView(with: state.currentDisplay.errorState)

        default:
            break
        }

//        self.segmentedControl.segmentedControl.selectedIndex = displays.firstIndex(of: state.kind) ?? 0
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

private extension NewWalletViewController {

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
//        displayData.delegate = self
//        displayData.balanceCellDelegate = self
    }

    func setupSegmetedControl() {
//        let buttons = displays.map { SegmentedControl.Button(name: $0.name) }
//        segmentedControl
//            .segmentedControl
//            .update(with: buttons, animated: true)
    }
}

//MARK: - WalletLeasingBalanceCellDelegate
extension NewWalletViewController: WalletLeasingBalanceCellDelegate {
    
    func walletLeasingBalanceCellDidTapStartLease(availableMoney: Money) {
        
        sendEvent.accept(.showStartLease(availableMoney))
    }
}


//MARK: - UITableViewDataSource
extension NewWalletViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].items[indexPath.row]
        switch row {
        case .emptyTopContent:
            return 100
            
        case .emptySegmentedControl:
            return containerView.segmentedHeight

        default:
            return 50
        }
    }
}

//MARK: - UITableViewDataSource
extension NewWalletViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].items[indexPath.row]
        switch row {
        case .emptyTopContent, .emptySegmentedControl:
            
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
                cell.selectionStyle = .none
            }
            return cell
            
        case .asset(let asset):
            return UITableViewCell()

        default:
            return UITableViewCell()
        }
    }
}
