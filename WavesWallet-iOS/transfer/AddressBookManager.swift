//
//  AddressBookManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class AddressBookManager {
    class func askForSaveAddress(parentController: UIViewController, address: String) {        
        let alert = UIAlertController(title: "Add to Address Book", message: "Enter a name for address", preferredStyle: .alert)
        
        var d: Disposable?
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text {
                saveAddressBook(name: name, address: address)
                if let d = d {
                    d.dispose()
                }
            }
        })
        alert.addAction(okAction)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Address name"
            let nameValid = textField.rx.text.orEmpty
                .map { $0.characters.count >= TransactionCell.minimalNameLength }
                .shareReplay(1)
            
            d = nameValid
                .bind(to: okAction.rx.isEnabled)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in })
        
        parentController.present(alert, animated: true, completion: nil)
    }
    
    class func saveAddressBook(name: String, address: String) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(AddressBookOld.self, value: [address, name], update: true)
        }
    }
    
    class func askForDeletion(parentController: UIViewController, address: String) {
        let message = "Are you sure you want to delete this address: \(address) from Address Book?"
        let alertView = UIAlertController(title: "Delete Address",
                                          message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Delete", style: .default) { _ in deleteAddressBook(address: address) }
        alertView.addAction(okAction)
        
        let canceAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertView.addAction(canceAction)
        parentController.present(alertView, animated: true, completion: nil)
    }
    
    class func deleteAddressBook(address: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.create(AddressBookOld.self, value: [address, nil], update: true)
        }
    }
    
}
