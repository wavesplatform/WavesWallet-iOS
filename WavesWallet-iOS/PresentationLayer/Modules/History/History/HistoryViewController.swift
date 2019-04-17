//
//  HistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift
import SwiftDate

fileprivate enum Constants {
    static let historyDateFormatterKey: String = "historyDateFormatterKey"
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    static let animationDurationReloadTabel: TimeInterval = 0.24
}

final class HistoryViewController: UIViewController {

    typealias Types = HistoryTypes

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: WalletSegmentedControl!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyTextLabel: UILabel!
    @IBOutlet weak var globalErrorView: GlobalErrorView!

    private var refreshControl: UIRefreshControl!

    private let disposeBag: DisposeBag = DisposeBag()
    private var isRefreshing: Bool = false
    private var snackError: String? = nil
    
    var presenter: HistoryPresenterProtocol!

    private lazy var leftRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerLeftSwipe(gesture:)))
    private lazy var rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerRightSwipe(gesture:)))
    private var sections: [HistoryTypes.ViewModel.Section] = []
    private var filters: [HistoryTypes.Filter] = []
    private let sendEvent: PublishRelay<Types.Event> = PublishRelay<Types.Event>()
    let tapCell: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = Constants.contentInset

        leftRightGesture.delegate = self
        leftRightGesture.direction = .left
        rightSwipeGesture.delegate = self
        rightSwipeGesture.direction = .right

        tableView.addGestureRecognizer(leftRightGesture)
        tableView.addGestureRecognizer(rightSwipeGesture)

        globalErrorView.retryDidTap = { [weak self] in
            guard let self = self else { return }
            self.sendEvent.accept(.refresh)
        }

        emptyView.isHidden = true
        setupLocalization()
        setupSegmentedControl()
        setupRefreshControl()
        setupSystem()
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        setupTopBarLine()
        setupBigNavigationBar()
        tableView.startSkeletonCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }

    @objc func changedLanguage() {
        setupLocalization()
        setupSegmentedControl()
        tableView.reloadData()
    }

    @objc func handlerLeftSwipe(gesture: UIGestureRecognizer) {

        if isHiddenSegmentedControl {
            return
        }

        var index = self.segmentedControl.segmentedControl.selectedIndex
        index = min(max(0, filters.count - 1), index + 1)

        sendEvent.accept(.changeFilter(filters[index]))
    }

    @objc func handlerRightSwipe(gesture: UIGestureRecognizer) {
        if isHiddenSegmentedControl {
            return
        }
        var index = self.segmentedControl.segmentedControl.selectedIndex
        index = max(0, index - 1)
        sendEvent.accept(.changeFilter(filters[index]))
    }

    private var isHiddenSegmentedControl: Bool {
        let frameSegmented = self.segmentedControl.convert(segmentedControl.frame, to: self.view)
        let barFrame = self.navigationController?.navigationBar.frame ?? CGRect.zero

        return barFrame.maxY > frameSegmented.maxY
    }
}

//MARK: - MainTabBarControllerProtocol
extension HistoryViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        tableView.setContentOffset(tableViewTopOffsetForBigNavBar(tableView), animated: true)
    }
}

// MARK: UIGestureRecognizerDelegate

extension HistoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: Localization

extension HistoryViewController: Localization {
    func setupLocalization() {
        navigationItem.title = Localizable.Waves.History.Navigationbar.title
        emptyTextLabel.text = Localizable.Waves.Asset.Header.notHaveTransactions
    }
}

// MARK: Bind UI

private extension HistoryViewController {
    
    func setupSystem() {
        
        let feedback: HistoryPresenterProtocol.Feedback = bind(self) { owner, state in
            
            let subscriptions = owner.uiSubscriptions(state: state)
            let events = owner.events()
            
            return Bindings(subscriptions: subscriptions,
                            events: events)
        }
        
        let readyViewFeedback: HistoryPresenter.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewWillAppear
                .map { _ in HistoryTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        let viewDidDisappearFeedback: HistoryPresenter.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewDidDisappear
                .map { _ in HistoryTypes.Event.viewDidDisappear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        
        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback,
                                     viewDidDisappearFeedback])
        
    }
    
    func events() -> [Signal<HistoryTypes.Event>] {

        let refreshEvent = tableView
            .rx
            .didRefreshing(refreshControl: refreshControl)
            .map { _ in HistoryTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in HistoryTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tap = tableView
            .rx
            .itemSelected
            .map { indexPath -> HistoryTypes.Event in
                return HistoryTypes.Event.tapCell(indexPath) 
            }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedDisplayEvent = segmentedControl.changedValue()
            .map { [weak self] selectedIndex -> HistoryTypes.Event in
                let filter = self?.filters[selectedIndex] ?? .all
                return .changeFilter(filter)
        }
        
        return [changedDisplayEvent, refreshEvent, tap, changedSpamList, sendEvent.asSignal()]
    }
    
    func uiSubscriptions(state: Driver<HistoryTypes.State>) -> [Disposable] {
        
        let subscriptionSections = state
            .drive(onNext: { [weak self] (state) in
            
                guard let self = self else { return }
                self.updateView(state: state)
            })
        
        return [subscriptionSections]
    }

    func updateView(state: Types.State) {

        if (!filters.elementsEqual(state.filters)) {
            filters = state.filters
            setupSegmentedControl()
            changeFilter(state.currentFilter)
        }

        sections = state.sections
        isRefreshing = state.isRefreshing
        changeFilter(state.currentFilter)

        updateErrorView(state: state)

        UIView.transition(with: tableView,
                          duration: Constants.animationDurationReloadTabel,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: {
                self.tableView.reloadData()
        }, completion: { _ in
            if state.isRefreshing == false {
                self.refreshControl.endRefreshing()
            }
        })
    }

    func updateErrorView(state: Types.State) {

        switch state.errorState {
        case .none:
            if let snackError = snackError {
                hideSnack(key: snackError)
            }
            snackError = nil
            self.globalErrorView.isHidden = true
            emptyView.isHidden = state.sections.count > 0

        case .error(let error):
            emptyView.isHidden = true
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
            guard let self = self else { return }
            self.sendEvent.accept(.refresh)
        }
    }

    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            guard let self = self else { return }
            self.sendEvent.accept(.refresh)
        })
    }

    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack() { [weak self] in
            guard let self = self else { return }
            self.sendEvent.accept(.refresh)
        }
    }
}

// MARK: - Setup

extension HistoryViewController {
    
    func setupSegmentedControl() {
        let buttons = filters.map { SegmentedControl.Button(name: $0.name) }
        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
    }
    
    func changeFilter(_ filter: HistoryTypes.Filter) {
        segmentedControl.segmentedControl.selectedIndex = filters.index(of: filter) ?? 0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transaction(let transaction):
            
            self.tapCell.onNext(transaction)
            
        default: break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            let skeletonCell: HistoryTransactionSkeletonCell = cell as! HistoryTransactionSkeletonCell
            skeletonCell.startAnimation()
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let model = sections[section]
        
        guard let firstItem = model.items.first else { return }
        
        switch firstItem {
        case .transactionSkeleton:
            (view as! HeaderSkeletonView).startAnimation()
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
      let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            return HistoryTransactionSkeletonCell.cellHeight()
            
        case .transaction:
            if indexPath.row == sections[indexPath.section].items.count - 1 {
                return HistoryTransactionCell.lastCellHeight()
            }
            return HistoryTransactionCell.cellHeight()
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HistoryHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sections[indexPath.section].items[indexPath.item]
        
        switch item {
        case .transactionSkeleton:
            let cell: HistoryTransactionSkeletonCell = tableView.dequeueCell()
            return cell
            
        case .transaction(let transaction):
            let cell: HistoryTransactionCell = tableView.dequeueAndRegisterCell()
            cell.update(with: transaction)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let model = sections[section]
        
        guard let firstItem = model.items.first else { return nil }
        
        switch firstItem {
        case .transaction:
            
            let view: HistoryHeaderView = tableView.dequeueAndRegisterHeaderFooter()
            
            if let date = model.date {
                let formatter = DateFormatter.uiSharedFormatter(key: Constants.historyDateFormatterKey)
                formatter.dateStyle = .long
                formatter.timeStyle = .none                
                view.update(with: formatter.string(from: date))
            }
            return view

        case .transactionSkeleton:
            
            let view: HeaderSkeletonView = tableView.dequeueAndRegisterHeaderFooter()
            
            return view
            
        }
    }
}

extension HistoryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
}
