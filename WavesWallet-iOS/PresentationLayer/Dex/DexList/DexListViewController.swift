//
//  DexListViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift


private enum Constants {
    static let contentInset = UIEdgeInsetsMake(8, 0, 0, 0)
}

final class DexListViewController: UIViewController {

    private var buttonSort = UIBarButtonItem(image: Images.topbarSort.image, style: .plain, target: nil, action: nil)
    private var buttonAdd = UIBarButtonItem(image: Images.topbarAddmarkets.image, style: .plain, target: nil, action: nil)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNoItems: UIView!
    
    @IBOutlet weak var labelNoItemsDescription: UILabel!
    @IBOutlet weak var labelNoItemsTitle: UILabel!
    @IBOutlet weak var buttonAddMarkets: UIButton!

    private var refreshControl: UIRefreshControl!

    var presenter : DexListPresenterProtocol!
    private var sections : [DexList.ViewModel.Section] = []
    private let sendEvent: PublishRelay<DexList.Event> = PublishRelay<DexList.Event>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton()
        setupLocalization()
        setupRefreshControl()
        
        tableView.contentInset = Constants.contentInset
        setupViewNoItems(isHidden: true)
                
        let feedback = bind(self) { owner, state -> Bindings<DexList.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexListPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexList.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }
}


// MARK: Feedback

fileprivate extension DexListViewController {
    func events() -> [Signal<DexList.Event>] {
        
        let refresh = refreshControl.rx.controlEvent(.valueChanged).map { DexList.Event.refresh }.asSignal(onErrorSignalWith: Signal.empty())

        let sortTapEvent = buttonSort.rx.tap.map { DexList.Event.tapSortButton }
            .asSignal(onErrorSignalWith: Signal.empty())
        let addTapEvent = buttonAdd.rx.tap.map { DexList.Event.tapAddButton }
            .asSignal(onErrorSignalWith: Signal.empty())
        let addTap2Event = buttonAddMarkets.rx.tap.map { DexList.Event.tapAddButton }
            .asSignal(onErrorSignalWith: Signal.empty())

        return [sendEvent.asSignal(), sortTapEvent, addTapEvent, addTap2Event, refresh]
    }
    
    func subscriptions(state: Driver<DexList.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                guard let strongSelf = self else { return }
                guard state.action != .none else { return }

                if state.action == .update {
                    strongSelf.sections = state.sections
                    strongSelf.tableView.reloadData()
                    strongSelf.refreshControl.endRefreshing()
                    strongSelf.setupViews(loadingDataState: state.isFirstLoadingData, isVisibleItems: state.isVisibleItems)
                }
            })

        return [subscriptionSections]
    }
}


//MARK: SetupUI

private extension DexListViewController {

    func setupLocalization() {
        title = Localizable.DexList.Navigationbar.title
        labelNoItemsTitle.text = Localizable.DexList.Label.decentralisedExchange
        labelNoItemsDescription.text = Localizable.DexList.Label.description
        buttonAddMarkets.setTitle(Localizable.DexList.Button.addMarkets, for: .normal)
    }
    
    func setupViews(loadingDataState: Bool, isVisibleItems: Bool) {
        if (loadingDataState) {
            setupViewNoItems(isHidden: true)
        }
        else {
            setupViewNoItems(isHidden: isVisibleItems)
        }
     
        setupButtons(loadingDataState: loadingDataState, isVisibleSortButton: isVisibleItems)
    }
    
    func setupViewNoItems(isHidden: Bool) {
        viewNoItems.isHidden = isHidden
    }
    
    func setupButtons(loadingDataState: Bool, isVisibleSortButton: Bool) {

        if !loadingDataState && isVisibleSortButton {
            navigationItem.rightBarButtonItems = [buttonAdd, buttonSort]
        }
        else if !loadingDataState {
            navigationItem.rightBarButtonItems = [buttonAdd]
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
}


//MARK: - UITableViewDelegate
extension DexListViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if let model = sections[indexPath.section].items[indexPath.row].model {
            sendEvent.accept(.tapAssetPair(model))
        }
    }
}

//MARK: - UITableViewDataSource

extension DexListViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .header:
            return DexListHeaderCell.cellHeight()
            
        case .model:
            return DexListCell.cellHeight()
            
        case .skeleton:
            return DexListSkeletonCell.cellHeight()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .header(let lastUpdate):
            let cell = tableView.dequeueCell() as DexListHeaderCell
            cell.update(with: lastUpdate)
            return cell
            
        case .model(let model):
            let cell: DexListCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell

        case .skeleton:
            let cell = tableView.dequeueCell() as DexListSkeletonCell
            cell.slide(to: .right)
            return cell
        }
    }

}
