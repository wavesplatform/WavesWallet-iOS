//
//  LanguagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HelloLanguagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var continueBtn: UIButton!

    let languages = DataManager.getLanguages()

    var chosenIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()


        Bundle.main.localizations
        let languages = NSLocale.preferredLanguages

        NSLocale.availableLocaleIdentifiers


        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        continueBtn.alpha = 0
    }

    @IBAction func continueWasPressed(_ sender: Any) {
        let nextVC = StoryboardManager.HelloStoryboard().instantiateViewController(withIdentifier: "InfoPagesViewController") as! InfoPagesViewController
        navigationController?.pushViewController(nextVC, animated: true)
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCellIdentifier", for: indexPath) as! LanguageTableCell

        let item = languages[indexPath.row]
        cell.labelTitle.text = item["title"]
        cell.iconLanguage.image = UIImage(named: item["icon"]!)

        if let index = chosenIndexPath, index == indexPath {
            cell.iconCheckmark.image = Images.on.image
        } else {
            cell.iconCheckmark.image = Images.off.image
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenIndexPath = indexPath
        tableView.reloadData()

        tableViewBottomConstraint.constant = 62
        UIView.animate(withDuration: 0.3) {
            self.continueBtn.alpha = 1.0
        }
    }
}
