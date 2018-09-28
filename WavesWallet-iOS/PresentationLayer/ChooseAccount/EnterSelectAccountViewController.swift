//
//  EnterSelectAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import MGSwipeTableCell


final class ChooseAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewNoResult: UIView!
    
    let accounts : [String] = ["Ol’ Dirty Bastard", "Some AccountName", "test account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBgBlueImage()

        title = "Choose account"
        createBackWhiteButton()
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        navigationItem.barTintColor = .white
        navigationItem.tintColor = .white
        navigationItem.titleTextAttributes = [.foregroundColor: UIColor.white]

        viewNoResult.isHidden = accounts.count > 0
        tableView.isHidden = accounts.count == 0
        
        tableView.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - MGSwipeTableCellDelegate
   
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
    
        let indexPath = tableView.indexPath(for: cell)!
        
        if index == 0 {
            
            let isSeed = true
            
            if isSeed {
                let controller = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
                
                controller.deleteBlock = {
                    cell.hideSwipe(animated: true)
                }
                controller.cancelBlock = {
                    cell.hideSwipe(animated: true)
                }
                controller.showInController(self)
            }
            else {
                let controller = UIAlertController(title: "Delete account", message: "Are you sure you want to delete this account?", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    cell.hideSwipe(animated: true)
                }
                
                let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
                    cell.hideSwipe(animated: true)
                }
                controller.addAction(cancel)
                controller.addAction(yes)
                present(controller, animated: true, completion: nil)
            }

            return false
        } else if index == 1 {
                let controller = storyboard?.instantiateViewController(withIdentifier: "EditAccountNameViewController") as! EditAccountNameViewController
                navigationController?.pushViewController(controller, animated: true)
        }

        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
    
        if direction == .rightToLeft {
            
            let edit = MGSwipeButton(title: "", icon: UIImage(named: "editaddress24Submit300"), backgroundColor: nil)
            edit.setEdgeInsets(UIEdgeInsetsMake(0, 15, 0, 0))
            edit.buttonWidth = 72

            let delete = MGSwipeButton.init(title: "", icon: UIImage(named: "deladdress24Error400"), backgroundColor: nil)
            delete.buttonWidth = 72
            return [delete, edit]
        }
        return nil
    }
   
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChouseAccountCell = tableView.dequeueAndRegisterCell()
        cell.delegate = self
        cell.labelTitle.text = accounts[indexPath.row]
        return cell
    }
}
