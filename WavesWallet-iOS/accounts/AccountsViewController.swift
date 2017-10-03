//
//  AccountsViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 16/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift
import RxRealm
import MGSwipeTableCell

struct AccountSection {
    var header: String
    var items: [Item]
}

extension AccountSection : AnimatableSectionModelType {
    typealias Item = AssetBalance
    
    var identity: String {
        return header
    }
    
    init(original: AccountSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class AccountsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    let bag = DisposeBag()
    var realm: Realm!
    
    let dataSource = RxTableViewSectionedReloadDataSource<AccountSection>()
    let sectionTitles = ["", "My Assets", "Other"]
    var objectsBySection = [Results<AssetBalance>]()
    var hiddenExpanded = [false, false, false]
    var hiddenAssetIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()
        setupUI()
        NodeManager.addGeneralBalances()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        WalletManager.updateBalances{ UIApplication.shared.isNetworkActivityIndicatorVisible = false }
    }
    
    func setupUI() {
        self.title = "Assets"
        setupRefreshControl()
        setupNavigationBar()
        setupTableView()
    }
    
    func setupTableView() {
        dataSource.configureCell = { (_, tv, indexPath, ab) in
            if let cell = tv.dequeueReusableCell(withIdentifier: "cell") as? AccountCell {
                cell.delegate = self
                cell.bindItem(ab)
                return cell
            }
            return UITableViewCell()
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        bindTableView()
    }
    
    func setupNavigationBar() {
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppColors.accentColor
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(sender: AnyObject) {
        WalletManager.updateBalances{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshControl.endRefreshing()
        }
    }
    
    func bindTableView() {
        /*let generalAssets = realm.objects(AssetBalance.self).filter("isGeneral == true").sorted(byKeyPath: "isHidden", ascending: true)
        let s0 = SectionModel(model: sectionTitles[0], items: generalAssets.toArray())
        
        let myPredicate = NSPredicate(format: "issueTransaction.sender = %@", WalletManager.getAddress())
        let myAssets = realm.objects(AssetBalance.self).filter(myPredicate).sorted(byKeyPath: "isHidden", ascending: true)
        let s1 = SectionModel(model: sectionTitles[1], items: myAssets.toArray())
        
        let otherAssets = realm.objects(AssetBalance.self)
            .filter("isGeneral == false && issueTransaction.sender != %@", WalletManager.getAddress())
            .sorted(byKeyPath: "isHidden", ascending: true)
        let s2 = SectionModel(model: sectionTitles[2], items: otherAssets.toArray())
        */
        
        objectsBySection.append(realm.objects(AssetBalance.self).filter("isGeneral == true").sorted(byKeyPath: "isHidden", ascending: true))
        
        let myPredicate = NSPredicate(format: "issueTransaction.sender = %@", WalletManager.getAddress())
        objectsBySection.append(realm.objects(AssetBalance.self).filter(myPredicate).sorted(byKeyPath: "isHidden", ascending: true))
        
        objectsBySection.append(
            realm.objects(AssetBalance.self)
                .filter("isGeneral == false && issueTransaction.sender != %@", WalletManager.getAddress())
                .sorted(byKeyPath: "isHidden", ascending: true)
        )
        
        hiddenAssetIds = realm.objects(AssetBalance.self).filter("isHidden == true").map{ $0.assetId }
        
        let o = objectsBySection.map{ Observable.collection(from: $0) }
        let items = Observable.combineLatest(o).map({ rr in
            rr.enumerated().map{ AccountSection(header: self.sectionTitles[$0], items: $1.toArray()) }
        })
        
        //let items = objectsBySection.enumerated().map{ SectionModel(model: sectionTitles[$0], items: $1.toArray()) }
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)

        //tableView.reloadData()
    }
    
    //var disposeBag = DisposeBag()
    
    /*func loadDataFromNode() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NodeManager.loadWavesBalance()
            .subscribe(onNext: {abs in
                try! self.realm.write {
                    self.realm.add(abs, update: true)
                }
                self.tableView.reloadSections([0], animationStyle: .automatic)
            }, onError: { err in
                print(err)
            })
            .addDisposableTo(disposeBag)
        
        NodeManager.loadBalances()
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl?.endRefreshing()
            })
            .subscribe(onNext: {abs in
                try! self.realm.write {
                    self.realm.add(abs, update: true)
                    self.realm.objects(AssetBalance.self).filter("assetId in %@", self.hiddenAssetIds)
                        .setValue(true, forKeyPath: "isHidden")
            
                    let generalAssetsIds = [""] + Environments.current.generalAssetIds.map{ $0.assetId }
                    self.realm.objects(AssetBalance.self).filter("assetId in %@", generalAssetsIds)
                        .setValue(true, forKeyPath: "isGeneral")
                    
                    let ids = abs.map{ $0.assetId}
                    let deleted = self.realm.objects(AssetBalance.self).filter("isGeneral = false AND NOT (assetId in %@)", ids)
                    self.realm.delete(deleted)
                }
                updateHiddenIds()
                tableView.reloadData()
            }, onError: { err in
                print(err)
            })
            .addDisposableTo(disposeBag)
    }*/

    
    // Table view data source
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsBySection[section].count
    }*/
    
    func objectForIndexPath(indexPath: IndexPath) -> AssetBalance? {
        return objectsBySection[indexPath.section][indexPath.row]
    }
    
   
    
    /*override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let sec = view as? UITableViewHeaderFooterView {
            sec.addBorder(edges: [.top, .bottom], colour: AppColors.greyBorderColor)
            sec.textLabel?.textColor = AppColors.greyBorderColor
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TransactionsViewController {
            vc.selectedAccount = sender as? AssetBalance
        }
    }

}

extension AccountsViewController: UITableViewDelegate {
    /*func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AccountCell
        
        let ab = objectForIndexPath(indexPath: indexPath)
        if let ab = ab {
            cell.delegate = self
            cell.bindItem(ab)
        }
        
        return cell
    }*/
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ab = objectForIndexPath(indexPath: indexPath)
        if let ab = ab {
            return (!ab.isHidden || hiddenExpanded[indexPath.section]) ? 60.0 : 0.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let items = objectsBySection[section].filter { $0.isHidden }
        let hidenCount = items.count

//        let hidenCount = objectsBySection[section].filter { $0.isHidden }.count
        return hidenCount > 0 ? 40.0 : 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let hidenCount = objectsBySection[section].filter { $0.isHidden }.count
        let items = objectsBySection[section].filter { $0.isHidden }
        let hidenCount = items.count

        let cell = tableView.dequeueReusableCell(withIdentifier: "countSectionFooter") as! CustomSectionHeader
        cell.title?.text = hidenCount > 0 && !hiddenExpanded[section] ? "\(hidenCount) hidden assets" : "Hide"
        cell.contentView.backgroundColor = hidenCount > 0 ? AppColors.lightSectionColor : AppColors.greyBorderColor
        cell.contentView.addBorder(edges: [.bottom], colour: AppColors.greyBorderColor, thickness: 0.5)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                if let `self` = self {
                    self.hiddenExpanded[section] = !self.hiddenExpanded[section]
                    self.tableView.reloadSections([section], animationStyle: .automatic)
                }
            })
            .disposed(by: bag)
        cell.contentView.addGestureRecognizer(tap)
        
        return cell.contentView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selAccount = objectForIndexPath(indexPath: indexPath), !selAccount.isHidden {
            self.performSegue(withIdentifier: "ShowAccountTransactions", sender: selAccount)
        }
    }
}

extension AccountsViewController: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if let cell = cell as? AccountCell
            , let ab = cell.assetBalance {
            try! realm.write {
                realm.create(AssetBalance.self, value: ["assetId": ab.assetId, "isHidden": !ab.isHidden], update: true)
            }
            let section = tableView.indexPath(for: cell)?.section ?? 0
            tableView.reloadSections([section], animationStyle: .automatic)
        }
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if let cell = cell as? AccountCell, let ab = cell.assetBalance {
            return !ab.assetId.isEmpty
        } else { return false }
    }
}
