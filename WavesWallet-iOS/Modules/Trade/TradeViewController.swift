//
//  TradeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import UIKit
import WavesSDK
import DomainLayer
import Extensions
import RxSwift
import RxCocoa
import RxFeedback

fileprivate enum Constants {
    static let updateTime: RxTimeInterval = 30
}

final class TradeViewController: UIViewController {

    @IBOutlet private weak var scrolledTableView: ScrolledContainerView!
    @IBOutlet private weak var tableViewSkeleton: UITableView!
    @IBOutlet private weak var errorView: GlobalErrorView!
    
    private var categories: [TradeTypes.DTO.Category] = []
    private var sectionSkeleton = TradeTypes.ViewModel.SectionSkeleton(rows: [])
    
    private var disposeBag: DisposeBag = DisposeBag()
    private var disposeBagTimer: DisposeBag = DisposeBag()
    private var errorSnackKey: String?

    var system: System<TradeTypes.State, TradeTypes.Event>!
    var selectedAsset: DomainLayer.DTO.Dex.Asset?
    weak var output: TradeModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        
        if selectedAsset != nil {
            createBackButton()
        }
        
        setupBigNavigationBar()

        scrolledTableView.containerViewDelegate = self
        scrolledTableView.scrollViewDelegate = self
        
        scrolledTableView.isHidden = true
        setupSystem()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: Images.viewexplorer18Black.image, style: .plain, target: self, action: #selector(searchTapped)),
                                              UIBarButtonItem(image: Images.orders.image, style: .plain, target: self, action: #selector(myOrdersTapped))]
        
        errorView.retryDidTap = { [weak self] in
            self?.system.send(.refresh)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }
    
    override func backTapped() {
        _ = navigationController?.popViewController(animated: true, completed: {
            self.output?.tradeDidDissapear()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeTopBarLine()
        scrolledTableView.viewControllerWillAppear()
        
        system.send(.refresIfNeed)
        
        Observable<Int>
            .interval(Constants.updateTime, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (value) in
                guard let self = self else { return }
                self.system.send(.refresh)
            })
            .disposed(by: disposeBagTimer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrolledTableView.viewControllerWillDissapear()
        disposeBagTimer = DisposeBag()
    }
    
    @objc private func myOrdersTapped() {
        output?.myOrdersTapped()
    }
    
    @objc private func searchTapped() {
        output?.searchTapped(selectedAsset: selectedAsset, delegate: self)
    }
    
    private func setupLocalization() {
        if let asset = selectedAsset {
            navigationItem.title = Localizable.Waves.Trade.title + " " + asset.shortName
        }
        else {
            navigationItem.title = Localizable.Waves.Trade.title
        }
    }
    
    @objc private func changedLanguage() {
        setupLocalization()
        system.send(.refresh)
    }
}

//MARK: - TradeRefreshOutput
extension TradeViewController: TradeRefreshOutput {
  
    func pairsDidChange() {
        system.send(.refresh)
    }
}

//MARK: - Feedback
private extension TradeViewController {
    
    func setupSystem() {
        
        let readyViewFeedback: (Driver<TradeTypes.State>) -> Signal<TradeTypes.Event> = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self.rx.viewWillAppear.take(1)
                .map { _ in TradeTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        let refreshEvent: (Driver<TradeTypes.State>) -> Signal<TradeTypes.Event> = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self.scrolledTableView.rx
                .didRefreshing(refreshControl: self.scrolledTableView.refreshControl!)
                .map { _ in .refresh }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        system
            .start(sideEffects: [readyViewFeedback, refreshEvent])
            .drive(onNext: { [weak self] (state) in

                guard let self = self else { return }
                switch state.uiAction {
                case .none:
                    return
                    
                case .update:
                    
                    self.categories = state.categories
                    self.hideErrorIfExist()
                    var segmentedItems: [NewSegmentedControl.SegmentedItem] = []
                    
                    for category in self.categories {
                        if category.isFavorite {
                            let image = NewSegmentedControl.SegmentedItem.image(.init(unselected: Images.iconFavEmpty.image, selected: Images.favorite14Submit300.image))
                            segmentedItems.append(image)
                        }
                        else {
                            segmentedItems.append(.title(category.name))
                        }
                    }
                    
                    self.hideErrorIfExist()
                    self.scrolledTableView.setup(segmentedItems: segmentedItems, tableDataSource: self, tableDelegate: self)
                    self.scrolledTableView.reloadData()
                    self.scrolledTableView.isHidden = false
                    self.tableViewSkeleton.isHidden = true
                    self.errorView.isHidden = true

                case .deleteRowAt(let indexPath):
                    self.categories = state.categories
                    self.scrolledTableView.updateTableWithAnimation(animation: .delete(indexPath))

                case .reloadRowAt(let indexPath):
                    self.categories = state.categories
                    self.scrolledTableView.updateTableWithAnimation(animation: .reload(indexPath))
                    
                case .updateSkeleton(let sectionSkeleton):
                    self.hideErrorIfExist()
                    
                    self.errorView.isHidden = true
                    self.scrolledTableView.isHidden = true
                    self.tableViewSkeleton.isHidden = false
                    
                    self.sectionSkeleton = sectionSkeleton
                    self.tableViewSkeleton.reloadData()
                    self.tableViewSkeleton.startSkeletonCells()

                case .didFailGetError(let error):
                    self.hideErrorIfExist()
                    
                    if state.categories.count > 0 {
                        switch error {
                        case .internetNotWorking:
                            self.errorSnackKey = self.showWithoutInternetSnack { [weak self] in
                               guard let self = self else { return }
                               self.system.send(.refresh)
                           }
                           
                       default:
                            self.errorSnackKey = self.showNetworkErrorSnack(error: error)
                       }
                        
                        self.scrolledTableView.isHidden = false
                        self.tableViewSkeleton.isHidden = true
                        self.errorView.isHidden = true
                    }
                    else {
                        
                        switch error {
                        case .internetNotWorking:
                            self.errorView.update(with: .init(kind: .internetNotWorking))
                            
                        default:
                            self.errorView.update(with: .init(kind: .serverError))
                        }
                        
                        self.errorView.isHidden = false
                        self.tableViewSkeleton.isHidden = true
                        self.scrolledTableView.isHidden = true
                    }
                }

                DispatchQueue.main.async {
                    self.scrolledTableView.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
}


//MARK: - UI
private extension TradeViewController {
    
    func hideErrorIfExist() {
           if let key = errorSnackKey {
               hideSnack(key: key)
               errorSnackKey = nil
           }
       }
    
    func setupHeaderShadow() {
        if let view = scrolledTableView.visibleTableView.headerView(forSection: 0) as? TradeFilterHeaderView {
            if scrolledTableView.topOffset - scrolledTableView.contentOffset.y <= scrolledTableView.smallTopOffset {
                view.addShadow()
            }
            else {
                view.removeShadow()
            }
        }
    }
    
}

//MARK: - TradeFilterHeaderViewDelegate
extension TradeViewController: TradeFilterHeaderViewDelegate {
    
    func tradeAltsHeaderViewDidTapFilter(filter: DomainLayer.DTO.TradeCategory.Filter, atCategory: Int) {
        system.send(.filterTapped(filter, atCategory: atCategory))
    }
    
    func tradeDidTapClear(atCategory: Int) {
        system.send(.deleteFilter(atCategory: atCategory))
    }
}

//MARK: ScrolledContainerViewDelegate
extension TradeViewController: ScrolledContainerViewDelegate {
    func scrolledContainerViewDidScrollToIndex(_ index: Int) {
        setupHeaderShadow()
        
        let category = categories[index]
        scrolledTableView.segmentedControl.isNeedShowBottomShadow = category.header == nil
    }
}

extension TradeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView != tableViewSkeleton else { return }

        setupHeaderShadow()
    }

}

//MARK: - UITableViewDelegate
extension TradeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView != tableViewSkeleton else { return }
        
        if let pair = categories.category(tableView).rows[indexPath.row].pair {
            output?.showTradePairInfo(pair: .init(amountAsset: pair.amountAsset,
                                                  priceAsset: pair.priceAsset,
                                                  isGeneral: pair.isGeneral))
        }
    }
}

//MARK: - UITableViewDataSource
extension TradeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard tableView != tableViewSkeleton else { return nil }
        
        let category = self.categories.category(tableView)
        
        if let filter = category.header?.filter {
            let view = tableView.dequeueAndRegisterHeaderFooter() as TradeFilterHeaderView
            view.update(with: filter)
            view.delegate = self
            return view
        }
        
        return nil
 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        guard tableView != tableViewSkeleton else { return 0 }
        let category = self.categories.category(tableView)
        
        if category.header?.filter != nil {
            return TradeFilterHeaderView.viewHeight()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == tableViewSkeleton {
            let row = sectionSkeleton.rows[indexPath.row]
            
            switch row {
            case .headerCell:
                return TradeHeaderSkeletonCell.viewHeight()

            case .defaultCell:
                return TradeSkeletonCell.viewHeight()
            }
        }
        
        let row = categories.category(tableView).rows[indexPath.row]

        switch row {
        case .pair:
            return TradeTableViewCell.viewHeight()
        case .emptyData:
            return tableView.frame.size.height / 2 + MyOrdersEmptyDataCell.viewHeight() / 2
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewSkeleton {
            return sectionSkeleton.rows.count
        }
        
        return categories.category(tableView).rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableViewSkeleton {
            let row = sectionSkeleton.rows[indexPath.row]
            
            switch row {
            case .headerCell:
                return tableView.dequeueAndRegisterCell() as TradeHeaderSkeletonCell
            
            case .defaultCell:
                return tableView.dequeueAndRegisterCell() as TradeSkeletonCell
            }
        }
        
        let category = categories.category(tableView)
        let row = category.rows[indexPath.row]

        switch row {
        case .pair(let pair):
            let cell = tableView.dequeueAndRegisterCell() as TradeTableViewCell
            cell.update(with: pair)
            cell.favoriteTappedAction = { [weak self] in
                guard let self = self else { return }
                self.system.send(.favoriteTapped(pair))
            }
            return cell

        case .emptyData:
            return tableView.dequeueAndRegisterCell() as MyOrdersEmptyDataCell
        }
    }
}

//MARK: - ScrolledContainerView
private extension ScrolledContainerView {
    
    enum Animation {
        case delete(IndexPath)
        case reload(IndexPath)
    }
    
    func updateTableWithAnimation(animation: Animation) {
        
        let isVisibleFavoriteTable = visibleTableView.tag == 0
        
        if isVisibleFavoriteTable {
            visibleTableView.performBatchUpdates({
                switch animation {
                case .delete(let indexPath):
                    self.visibleTableView.deleteRows(at: [indexPath], with: .fade)
                      
                case .reload(let indexPath):
                    self.visibleTableView.reloadRows(at: [indexPath], with: .fade)
                }
            }) { (_) in
                self.reloadData()
            }
        }
        else {
            reloadData()
        }
      
    }
}
