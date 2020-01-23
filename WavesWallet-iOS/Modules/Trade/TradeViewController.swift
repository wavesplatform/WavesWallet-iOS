//
//  TradeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import WavesSDK
import DomainLayer
import Extensions
import RxSwift
import RxCocoa
import RxFeedback

final class TradeViewController: UIViewController {

    @IBOutlet private weak var scrolledTableView: ScrolledContainerView!
    @IBOutlet private weak var tableViewSkeleton: UITableView!
    
    private var categories: [TradeTypes.DTO.Category] = []
    private var sectionSkeleton = TradeTypes.ViewModel.SectionSkeleton(rows: [])
    private let disposeBag: DisposeBag = DisposeBag()
    
    var system: System<TradeTypes.State, TradeTypes.Event>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localizable.Waves.Trade.title
        setupBigNavigationBar()

        scrolledTableView.containerViewDelegate = self
        scrolledTableView.scrollViewDelegate = self
        scrolledTableView.segmentedControl.isNeedShowBottomShadow = false
        
        scrolledTableView.isHidden = true
        setupSystem()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: Images.viewexplorer18Black.image, style: .plain, target: self, action: #selector(searchTapped)),
                                              UIBarButtonItem(image: Images.orders.image, style: .plain, target: self, action: #selector(myOrdersTapped))]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewSkeleton.startSkeletonCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeTopBarLine()
        tableViewSkeleton.startSkeletonCells()
        scrolledTableView.viewControllerWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrolledTableView.viewControllerWillDissapear()
    }
    
    @objc private func myOrdersTapped() {
        let vc = MyOrdersModuleBuilder().build()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func searchTapped() {
        print("test")
        
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

                    self.scrolledTableView.setup(segmentedItems: segmentedItems, tableDataSource: self, tableDelegate: self)
                    self.scrolledTableView.reloadData()
                    self.scrolledTableView.isHidden = false
                    self.tableViewSkeleton.isHidden = true
                    
                case .updateSkeleton(let sectionSkeleton):
                    self.sectionSkeleton = sectionSkeleton
                    self.tableViewSkeleton.reloadData()
                    
                case .didFailGetError(let error):
                    print("error")
                
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
    
    func setupHeaderShadow() {
        
        if let view = scrolledTableView.visibleTableView.headerView(forSection: 0) as? TradeAltsHeaderView {
            if scrolledTableView.topOffset - scrolledTableView.contentOffset.y <= scrolledTableView.smallTopOffset {
                view.addShadow()
            }
            else {
                view.removeShadow()
            }
        }
    }
    
}

//MARK: ScrolledContainerViewDelegate
extension TradeViewController: ScrolledContainerViewDelegate {
    func scrolledContainerViewDidScrollToIndex(_ index: Int) {
        setupHeaderShadow()
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
        
    }
}

//MARK: - UITableViewDataSource
extension TradeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard tableView != tableViewSkeleton else { return nil }
        
        let category = self.categories[tableView.tag]
        guard category.filters.count > 0 else { return nil }
        let names = category.filters.map {$0.name}
        
        let view = tableView.dequeueAndRegisterHeaderFooter() as TradeAltsHeaderView
        view.update(with: names)
        return view
 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        guard tableView != tableViewSkeleton else { return 0 }
        let category = self.categories[tableView.tag]
        guard category.filters.count > 0 else { return 0 }

        return TradeAltsHeaderView.viewHeight()
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
        
        let row = categories[tableView.tag].rows[indexPath.row]

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
        
        return categories[tableView.tag].rows.count
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
        
        let category = categories[tableView.tag]
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
