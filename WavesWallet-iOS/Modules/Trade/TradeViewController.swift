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
    private let disposeBag: DisposeBag = DisposeBag()

    var system: System<TradeTypes.State, TradeTypes.Event>!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Waves.Trade.title
        setupBigNavigationBar()

        let image = NewSegmentedControl.SegmentedItem.image(.init(unselected: Images.iconFavEmpty.image, selected: Images.favorite14Submit300.image))
//        let segmentedTitles = ["BTC", WavesSDKConstants.wavesAssetId, Localizable.Waves.Trade.Segment.alts, Localizable.Waves.Trade.Segment.fiat]
//        scrolledTableView.setup(segmentedItems: [image] + segmentedTitles.map { .title($0)}, tableDataSource: self, tableDelegate: self)
        scrolledTableView.containerViewDelegate = self
        scrolledTableView.scrollViewDelegate = self
        scrolledTableView.segmentedControl.isNeedShowBottomShadow = false
        
        scrolledTableView.isHidden = true
        setupSystem()
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
    
    private func setupHeaderShadow() {
        
        if let view = scrolledTableView.visibleTableView.headerView(forSection: 0) as? TradeAltsHeaderView {
            if scrolledTableView.topOffset - scrolledTableView.contentOffset.y <= scrolledTableView.smallTopOffset {
                view.addShadow()
            }
            else {
                view.removeShadow()
            }
        }
    }
    
    private func setupSystem() {
        
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
                    
                    for category in state.categories {
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
            if indexPath.row == 0 {
                return TradeHeaderSkeletonCell.viewHeight()
            }
            
            return TradeSkeletonCell.viewHeight()
        }
        
        return TradeTableViewCell.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewSkeleton {
            return 6
        }
        
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableViewSkeleton {
            if indexPath.row == 0 {
                let cell = tableView.dequeueAndRegisterCell() as TradeHeaderSkeletonCell
                return cell
            }
            
            let cell = tableView.dequeueAndRegisterCell() as TradeSkeletonCell
            cell.startAnimation()
            return cell
        }
        
        let cell = tableView.dequeueAndRegisterCell() as TradeTableViewCell
        cell.test()
        return cell
    }
}
