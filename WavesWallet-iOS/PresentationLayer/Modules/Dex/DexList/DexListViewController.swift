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


fileprivate enum Constants {
    static let contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 0)
    static let updateTime: RxTimeInterval = 30
}

final class DexListViewController: UIViewController {

    private var buttonSort = UIBarButtonItem(image: Images.topbarSort.image, style: .plain, target: nil, action: nil)
    private var buttonAdd = UIBarButtonItem(image: Images.topbarAddmarkets.image, style: .plain, target: nil, action: nil)

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewNoItems: UIView!
    
    @IBOutlet private weak var labelNoItemsDescription: UILabel!
    @IBOutlet private weak var labelNoItemsTitle: UILabel!
    @IBOutlet private weak var buttonAddMarkets: UIButton!
    @IBOutlet private weak var globalErrorView: GlobalErrorView!
    
    private var refreshControl: UIRefreshControl!

    var presenter : DexListPresenterProtocol!
    private var sections : [DexList.ViewModel.Section] = []
    private let sendEvent: PublishRelay<DexList.Event> = PublishRelay<DexList.Event>()
    private var disposeBag = DisposeBag()
    private var errorSnackKey: String?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
        
        globalErrorView.retryDidTap = { [weak self] in
            self?.sendEvent.accept(.refresh)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        
        Observable<Int>.interval(Constants.updateTime, scheduler: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] (value) in
            self?.sendEvent.accept(.refresh)
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTopBarLine()
    }

    @objc func changedLanguage() {
        setupLocalization()        
        tableView.reloadData()
    }
}

// MARK: Localization

extension DexListViewController: Localization {
    func setupLocalization() {
        navigationItem.title = Localizable.Waves.Dexlist.Navigationbar.title
        labelNoItemsTitle.text = Localizable.Waves.Dexlist.Label.decentralisedExchange
        labelNoItemsDescription.text = Localizable.Waves.Dexlist.Label.description
        buttonAddMarkets.setTitle(Localizable.Waves.Dexlist.Button.addMarkets, for: .normal)
    }
}

// MARK: Feedback

fileprivate extension DexListViewController {
    func events() -> [Signal<DexList.Event>] {
        
        let refresh = refreshControl.rx.controlEvent(.valueChanged).map { DexList.Event.refresh }.asSignal(onErrorSignalWith: Signal.empty())

        let sortTapEvent = buttonSort.rx.tap.map { DexList.Event.tapSortButton(self) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let addTapEvent = buttonAdd.rx.tap.map { DexList.Event.tapAddButton(self) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let addTap2Event = buttonAddMarkets.rx.tap.map { DexList.Event.tapAddButton(self) }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedSpamList = NotificationCenter.default.rx
            .notification(.changedSpamList)
            .map { _ in DexList.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        return [sendEvent.asSignal(), sortTapEvent, addTapEvent, addTap2Event, refresh, changedSpamList]
    }
    
    func subscriptions(state: Driver<DexList.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                guard let strongSelf = self else { return }
               
                switch state.action {
                    
                case .update:
                        strongSelf.hideErrorIfExist()
                        strongSelf.tableView.isHidden = false
                        strongSelf.globalErrorView.isHidden = true
                        strongSelf.sections = state.sections
                        strongSelf.tableView.reloadData()
                        strongSelf.refreshControl.endRefreshing()
                        strongSelf.setupViews(loadingDataState: state.isFirstLoadingData, isVisibleItems: state.isVisibleItems)
                    
                case .didFailGetModels(let error):
                    strongSelf.hideErrorIfExist()
                    strongSelf.setupErrorState(error: error, isFirstLoadingData: state.isFirstLoadingData)
                    
                    
                default:
                    break
                }
            })

        return [subscriptionSections]
    }
}

//MARK: - DexListRefreshOutput
extension DexListViewController: DexListRefreshOutput {
    
    func refreshPairs() {
        sendEvent.accept(.refresh)
    }
}

//MARK: SetupUI

private extension DexListViewController {

    func hideErrorIfExist() {
        if let key = errorSnackKey {
            hideSnack(key: key)
            errorSnackKey = nil
        }
    }
    func setupErrorState(error: NetworkError, isFirstLoadingData: Bool) {
        
        refreshControl.endRefreshing()
        
        if isFirstLoadingData {
            globalErrorView.isHidden = false
            tableView.isHidden = true
            
            switch error {
            case .internetNotWorking:
                globalErrorView.update(with: .init(kind: .internetNotWorking))
                
            default:
                globalErrorView.update(with: .init(kind: .serverError))
            }
        }
        else {
            globalErrorView.isHidden = true
            tableView.isHidden = false
            
            switch error {
            case .internetNotWorking:
                errorSnackKey = showWithoutInternetSnack { [weak self] in
                    self?.sendEvent.accept(.refresh)
                }
                
            default:
                errorSnackKey = showNetworkErrorSnack(error: error)
            }
            
        }
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
