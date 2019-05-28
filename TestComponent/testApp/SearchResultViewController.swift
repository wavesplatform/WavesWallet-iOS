//
//  SearchResultViewController.swift
//  testApp
//
//  Created by Pavel Gubin on 5/21/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    
    var initialY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewContainer.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 251/255, alpha: 1)
        searchBar.delegate = self
        searchBar.placeholder = "Search"
    }
    
    override func didMove(toParent parent: UIViewController?) {
        print("sdsd")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewContainer.frame.origin.y = self.initialY
        }) { (complete) in
            self.dismiss(animated: false, completion: nil)
        }
//        self.dismiss(animated: true, completion: nil)
        return()
            
        UIView.animate(withDuration: 0.3, animations: {
            self.viewContainer.frame.origin.y = self.initialY
            self.view.alpha = 0
        }) { (complete) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: HistoryTransactionCell! = tableView.dequeueReusableCell(withIdentifier: "HistoryTransactionCell") as? HistoryTransactionCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("HistoryTransactionCell", owner: nil, options: nil)?.last as? HistoryTransactionCell
        }
        
        cell.viewHistory.labelTitle.text = "table \(tableView.tag + 1), row \(indexPath.row + 1)"
        return cell
    }
}
