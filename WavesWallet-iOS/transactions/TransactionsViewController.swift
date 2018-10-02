//
//  FirstViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 12/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import RxDataSources

import RealmSwift
import RxRealm

class TransactionsViewController: UIViewController {}
    
//    typealias TitleForHeaderInSection<S: SectionModelType> = (TableViewSectionedDataSource<S>, Int) -> String?
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var receiveButton: UIButton!
//    @IBOutlet weak var selectAssetView: UIView!
//
//    var headerView: UIView!
//
//    var selectedAccount: AssetBalance?
//
//    var disposeBag = DisposeBag()
//    var kHeaderHeight: CGFloat = 160.0
//    let kContentOffset: CGFloat = 35
//
//    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
//    private var transactions: Results<BasicTransaction>?
//    var realm: Realm!
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
//
//    func getStartOfDay(ts: Int64) -> Int64 {
//        let s = Calendar.current.startOfDay(for: Date(milliseconds: ts))
//        return Int64(s.millisecondsSince1970)
//    }
//
//    func groupedByDay(txs: Results<BasicTransaction>) -> [SectionModel<Int64, BasicTransaction>] {
//        var groups = [Int64: [BasicTransaction]]()
//        for tx in txs {
//            let key = getStartOfDay(ts: tx.timestamp)
//            if groups.keys.contains(key) == false {
//                groups[key] = [BasicTransaction]()
//            }
//            groups[key]?.append(tx)
//        }
//
//        var sections = [SectionModel<Int64, BasicTransaction>]()
//        for g in groups.enumerated() {
//            sections.append(SectionModel(model: g.element.key, items: g.element.value))
//        }
//
//        return sections.sorted { $0.model > $1.model }
//    }
//
////    var selectAccountController: SelectAccountViewController {
////        get {
////            let vc = childViewControllers.first(where: { $0 is SelectAccountViewController })
////            return vc as! SelectAccountViewController
////        }
////    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        realm = try! Realm()
//
//        setupNavigationBar()
//        setupTableView()
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
////        WalletManager.updateTransactions{ UIApplication.shared.isNetworkActivityIndicatorVisible = false }
//
//        setupTableBinding()
//    }
//
//    func setupNavigationBar() {
//        self.navigationItem.backBarButtonItem?.title = ""
//    }
//
//    var refreshControl = UIRefreshControl()
//    func setupRefreshControl() {
//        refreshControl.tintColor = AppColors.accentColor
//        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
//
//        let f = refreshControl.frame
//        let yOffset: CGFloat = selectedAccount == nil ? -kContentOffset : (kHeaderHeight - kContentOffset)
//        refreshControl.bounds = CGRect(x: f.origin.x, y: yOffset, width: f.width, height: f.height)
//        tableView.addSubview(refreshControl)
//    }
//
//    @objc func refresh(sender: AnyObject) {
////        WalletManager.updateTransactions{
////            UIApplication.shared.isNetworkActivityIndicatorVisible = false
////            self.refreshControl.endRefreshing()
////        }
//    }
//
////    lazy var selectedAsset: Driver<AssetBalance?> = {
////        if let selAcc = self.selectedAccount {
////            self.selectAccountController.selectedAccount.value = selAcc
////            return self.selectAccountController.selectedAccount.asDriver()
////        } else {
////            return Driver.just(nil)
////        }
////    }()
//
//    /*func loadTransactionFromNode() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        Observable.merge(NodeManager.loadTransaction(), NodeManager.loadPendingTransaction())
//            .do(onNext: { _ in
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                self.refreshControl.endRefreshing()
//            })
//            .subscribe(onNext: {txs in
//                try! self.realm.write {
//                    self.realm.add(txs, update: true)
//                    self.realm.add(txs.map { tx in
//                        let bt = BasicTransaction(tx: tx)
//                        bt.addressBook = self.realm.create(AddressBook.self, value: ["address": bt.counterParty], update: true)
//                        return bt
//                    }, update: true)
//                }
//            })
//            .addDisposableTo(disposeBag)
//    }*/
//
//    lazy var configureCell: ConfigureCell<SectionModel<Int64, BasicTransaction>> = { (_, tv, indexPath, tx) in
//        if let cell = tv.dequeueReusableCell(withIdentifier: "Cell") as? TransactionCell {
//            cell.bindItem(tx, parentController: self)
//            return cell
//        }
//        return UITableViewCell()
//    }
//
//    lazy var titleForHeaderInSection: TitleForHeaderInSection<SectionModel<Int64, BasicTransaction>> = { dataSource, sectionIndex in
//        return DateUtil.formatStartOfDay(dataSource[sectionIndex].model)
//    }
//
//    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Int64, BasicTransaction>>(configureCell: configureCell,
//                                                                                                      titleForHeaderInSection: titleForHeaderInSection)
//
//    func findFullTransaction(basicTx: BasicTransaction) -> Transaction? {
//        switch basicTx.type {
//        case 4:
//            return realm.object(ofType: TransferTransaction.self, forPrimaryKey: basicTx.id)
//        case 7:
//            return realm.object(ofType: ExchangeTransaction.self, forPrimaryKey: basicTx.id)
//        default:
//            return realm.object(ofType: Transaction.self, forPrimaryKey: basicTx.id)
//        }
//    }
//
//    func updateHeaderView() {
//        let effectiveHeight = kHeaderHeight - kContentOffset
//        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: self.view.bounds.width, height: kHeaderHeight)
//        if tableView.contentOffset.y < -effectiveHeight {
//            headerRect.origin.y = tableView.contentOffset.y
//            headerRect.size.height = -tableView.contentOffset.y + kContentOffset
//        }
//        headerView.frame = headerRect
//        headerView.layoutSubviews()
//    }
//
//    func setupTableView() {
//        tableView.sectionFooterHeight = 0
//        tableView.separatorColor = AppColors.greyBorderColor
//
//        headerView = tableView.tableHeaderView
//        headerView.backgroundColor = AppColors.mainBgColor
//        tableView.tableHeaderView = nil
//
//        if selectedAccount == nil {
//            //self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.01))
//            kHeaderHeight = 0
//            self.title = "History"
//        } else {
//            tableView.addSubview(headerView)
//        }
//
//        let effectiveHeight = kHeaderHeight - kContentOffset
//        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
//        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
//
//        updateHeaderView()
//
//        setupRefreshControl()
//
//        tableView.rx
//            .modelSelected(BasicTransaction.self)
//            .subscribe(onNext:  { basicTx in
//                if let tx = self.findFullTransaction(basicTx: basicTx) {
//                    let vc = StoryboardManager.transactionDetailViewController(tx: tx)
//                    if let nav = vc as? UINavigationController
//                        , let txVc = nav.topViewController as? BaseTransactionDetailViewController {
//                        txVc.tx = tx
//                        txVc.basicTx = basicTx
//                    }
//                    self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: vc)
//
//                    vc.modalPresentationStyle = .custom
//                    vc.transitioningDelegate = self.halfModalTransitioningDelegate
//                    self.present(vc, animated: true, completion: nil)
//                    //self.tableView.deselectRow(at: indexPath, animated: true)
//                }
//            })
//            .disposed(by: disposeBag)
//
//        tableView.rx
//            .setDelegate(self)
//            .disposed(by: disposeBag)
//
//    }
//
//    func setupTableBinding() {
//        selectedAsset.asObservable().subscribe(onNext: { self.bindTableView(asset: $0) })
//            .disposed(by: disposeBag)
//    }
//
//    fileprivate var resultsBag = DisposeBag()
//
//    func bindTableView(asset: AssetBalance?) {
//        resultsBag = DisposeBag()
//
//        let realm = try! Realm()
//        transactions = realm.objects(BasicTransaction.self).sorted(byKeyPath: "timestamp", ascending: false)
//        if let ab = asset {
//            transactions = transactions?.filter("assetId == %@", ab.assetId)
//        }
//
//        if let transactions = transactions {
//            let o = Observable.collection(from: transactions)
//                .map({txs in
//                    return self.groupedByDay(txs: txs)
//                })
//                o
//                .subscribeOn(MainScheduler.instance)
//                .bind(to: tableView.rx.items(dataSource: dataSource))
//                .disposed(by: resultsBag)
//
//        }
//    }
//
//    @IBAction func onSend(_ sender: Any) {
//        if let ab = selectedAccount {
//            navigationController?.pushViewController(StoryboardManager.sendViewController(asset: ab), animated: true)
//        }
//    }
//
//    @IBAction func onRequisite(_ sender: Any) {
//        if let ab = selectedAccount {
//            navigationController?.pushViewController(StoryboardManager.receiveViewController(asset: ab), animated: true)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
//}
//
//
//extension TransactionsViewController : UITableViewDelegate {
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        //header.contentView.backgroundColor = AppColors.lightSectionColor
//        header.textLabel?.textColor = AppColors.greyText
//        header.textLabel?.font = UIFont.systemFont(ofSize: 11, weight: .light)
//        //header.addBorder(edges: [.top, .bottom], colour: AppColors.greyBorderColor)
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 28
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        updateHeaderView()
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? TransactionCell {
//            cell.toggelBlinkAnimation()
//        }
//    }
//    /*
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
//        let absoluteTop: CGFloat = 0
//        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
//        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
//        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
//
//        var newHeight = self.headerHeightConstraint.constant
//        if isScrollingDown {
//            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
//        } else if isScrollingUp {
//            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
//        }
//
//        if newHeight != self.headerHeightConstraint.constant {
//            self.headerHeightConstraint.constant = newHeight
//        }
//
//
//        self.previousScrollOffset = scrollView.contentOffset.y
//    }*/
//
//}
//
