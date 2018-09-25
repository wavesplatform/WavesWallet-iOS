//
//  AddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 06/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

class AddressBookViewControllerOld: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let selectedAddress: Variable<AddressBook?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAddresses()
    }

    func fetchAddresses() {
        let realm = try! Realm()
        let rAddresses = realm.objects(AddressBook.self).filter("name != nil")
        
        let items = Observable.array(from: rAddresses)
        
        let selBg = UIView()
        selBg.backgroundColor = AppColors.wavesColor
        
        items
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.address
            }
            .disposed(by: disposeBag)
        
        
        tableView.rx
            .modelSelected(AddressBook.self)
            .subscribe(onNext:  { value in
                self.selectedAddress.value = value
                print("Tapped `\(value)`")
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

}
