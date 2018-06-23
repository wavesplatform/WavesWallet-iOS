//
//  LanguagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class LanguagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueBtnBotConstraint: NSLayoutConstraint!
    
    let icons = ["flag18Britain", "flag18Rus", "flag18China", "flag18Korea", "flag18Turkey", "flag18Hindi", "flag18Danish", "flag18Nederland"]
    let languages = ["English", "Русский", "中文(简体)", "한국어", "Türkçe", "हिन्दी", "Dansk", "Nederlands"]
    
    var chosenIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
    }
    
    func setupConstraints() {
        if Platform.isIphoneX || Platform.isIphonePlus  {
            logoTopConstraint.constant = 68
            continueBtnBotConstraint.constant = 24
        }
        else if Platform.isIphone5{
            continueBtnBotConstraint.constant = 12
            logoTopConstraint.constant = 68
        }
        else {
            logoTopConstraint.constant = 44
            continueBtnBotConstraint.constant = 24
        }
    }
    
    @IBAction func continueWasPressed(_ sender: Any) {
        let nextVC = StoryboardManager.HelloStoryboard().instantiateViewController(withIdentifier: "InfoPagesViewController") as! InfoPagesViewController
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCellIdentifier", for: indexPath) as! LanguageTableCell
        cell.labelTitle.text = languages[indexPath.row]
        cell.iconLanguage.image = UIImage(named: icons[indexPath.row])
        
        if let index = chosenIndexPath,  index == indexPath{
            cell.iconCheckmark.image = UIImage(named: "on")
        }
        else {
            cell.iconCheckmark.image = UIImage(named: "off")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenIndexPath = indexPath
        tableViewBottomConstraint.constant = 62
        continueBtn.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.continueBtn.alpha = 1.0
        }
        tableView.reloadData()
    }
}
