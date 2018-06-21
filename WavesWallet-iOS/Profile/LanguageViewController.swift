//
//  LanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


class LanguageTableCell : UITableViewCell {
    @IBOutlet weak var iconLanguage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconCheckmark: UIImageView!
    
}

class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let icons = ["flag18Britain", "flag18Rus", "flag18China", "flag18Korea", "flag18Turkey", "flag18Hindi", "flag18Danish", "flag18Nederland"]
    let languages = ["English", "Русский", "中文(简体)", "한국어", "Türkçe", "हिन्दी", "Dansk", "Nederlands"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        navigationController?.navigationBar.barTintColor = .white
        title = "Language"
    }

    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCell") as! LanguageTableCell
        
        cell.labelTitle.text = languages[indexPath.row]
        cell.iconLanguage.image = UIImage(named: icons[indexPath.row])
        if indexPath.row == 0 {
            cell.iconCheckmark.image = UIImage(named: "on")
        }
        else {
            cell.iconCheckmark.image = UIImage(named: "off")
        }
        return cell
    }
}
