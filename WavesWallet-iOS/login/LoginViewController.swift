//
//  LoginViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa


class LoginViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let bag = DisposeBag()
    
    var rWallets: Results<WalletItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchWallets()
    }

    @IBAction func onEdit(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    
    func fetchWallets() {
        rWallets = WalletManager.getWalletsRealm().objects(WalletItem.self)
            
        let items = Observable.collection(from: rWallets)
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.address
            }
            .disposed(by: bag)
        
        tableView.rx
            .modelSelected(WalletItem.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:  { wallet in
                WalletManager.didLogin(toWallet: wallet)
            })
            .disposed(by: bag)
        
        tableView.rx.itemDeleted.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:  { indexPath in
                let wallet = self.rWallets[indexPath.row]
                self.askForDeletion(wallet: wallet)
            })
            .disposed(by: bag)

    }
    
    func deleteWallet(wallet: WalletItem) {
        let realm = WalletManager.getWalletsRealm()
        let publicKey = wallet.publicKey
        try! realm.write {
            realm.delete(wallet)
        }
        
        if let err = WalletManager.removePrivateKey(publicKey: publicKey) {
            presentBasicAlertWithTitle(title: err.localizedDescription)
        }
    }
    
    func askForDeletion(wallet: WalletItem) {
        let message = "Are you sure you want to delete \(wallet.name) wallet?"
        let warning = "Please confirm you have backed up your wallet seed elsewhere otherwise any money in this wallet will be inaccessible!!! "
        let alertView = UIAlertController(title: "Delete Wallet",
                                          message: warning + message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Delete", style: .default) { _ in self.deleteWallet(wallet: wallet) }
        alertView.addAction(okAction)
        
        let canceAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertView.addAction(canceAction)
        self.present(alertView, animated: true, completion: nil)

    }

}
