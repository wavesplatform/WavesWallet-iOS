//
//  AddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ChooseAddressBookCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var iconCheckmark: UIImageView!
    @IBOutlet weak var buttonEdit: UIButton!
}

protocol ChooseAddressBookViewControllerDelegate: class {
    
    func chooseAddressBookViewControllerDidChooseAddress(_ address: String)
}

class ChooseAddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var delegate: ChooseAddressBookViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldSearch: UITextField!

    var isSearchMode = false
    
    var addresses = ["Alex Jeff", "Bob", "Big Boobs", "Bork Adam", "MaksTorch", "Mr. Big Mike", "Ms. Jane"]
    var searchAddreses : [String] = []
    
    var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTapped(_ sender: Any) {
   
        let controller = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        controller.isAddMode = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - UITextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchDidChange(_ sender: Any) {
  
        isSearchMode = textFieldSearch.text!.count > 0
        searchAddreses.removeAll()
        
        if isSearchMode {
            for value in addresses {
                if (value.lowercased() as NSString).range(of: textFieldSearch.text!.lowercased()).location != NSNotFound {
                    searchAddreses.append(value)
                }
            }
        }
        tableView.reloadData()
    }
    
    func editTapped(_ sender: UIButton) {
        
        let index = sender.tag
        let controller = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEditMode {
            return
        }
        
        let title = isSearchMode ? searchAddreses[indexPath.row] : addresses[indexPath.row]
        delegate?.chooseAddressBookViewControllerDidChooseAddress(title)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchAddreses.count : addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAddressBookCell") as! ChooseAddressBookCell
        cell.buttonEdit.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
        let title = isSearchMode ? searchAddreses[indexPath.row] : addresses[indexPath.row]
        cell.labelTitle.text = title
        cell.buttonEdit.tag = indexPath.row
        
        if isEditMode {
            cell.iconCheckmark.isHidden = true
            cell.buttonEdit.isHidden = false
        }
        return cell
    }
}
