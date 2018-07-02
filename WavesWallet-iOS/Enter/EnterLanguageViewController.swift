//
//  EnterLanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class EnterLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    let languages = DataManager.getLanguages()

    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBgBlueImage()
        self.buttonConfirm.alpha = 0
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        if tableView.contentInset.bottom == 0 {
            UIView.animate(withDuration: 0.3) {
                tableView.contentInset.bottom = 75
                self.buttonConfirm.alpha = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCell", for: indexPath) as! LanguageTableCell
        
        let item = languages[indexPath.row]
        cell.labelTitle.text = item["title"]
        cell.iconLanguage.image = UIImage(named: item["icon"]!)
        
        if indexPath.row == selectedIndex {
            cell.iconCheckmark.image = UIImage(named: "on")
        }
        else {
            cell.iconCheckmark.image = UIImage(named: "off")
        }
        
        return cell
    }
}
