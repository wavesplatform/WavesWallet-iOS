//
//  LanguagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
    static let tableViewBottom: CGFloat = 62
    static let animationDuration: TimeInterval = 0.24
}

protocol HelloLanguagesModuleOutput: AnyObject {
    func languageDidSelect(language: Language)
    func userFinishedChangeLanguage()
}

final class HelloLanguagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var continueBtn: UIButton!

    private var languages: [Language] = {
        return Language.list
    }()

    private var chosenIndexPath: IndexPath?

    weak var output: HelloLanguagesModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.contentInset = Constants.contentInset
        continueBtn.alpha = 0
    }

    @IBAction func continueWasPressed(_ sender: Any) {
        output?.userFinishedChangeLanguage()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCellIdentifier", for: indexPath) as! LanguageTableCell

        let item = languages[indexPath.row]
        cell.labelTitle.text = item.title
        cell.iconLanguage.image = UIImage(named: item.icon)

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

        tableViewBottomConstraint.constant = Constants.tableViewBottom
        UIView.animate(withDuration: Constants.animationDuration) {
            self.continueBtn.alpha = 1.0
        }

        let item = languages[indexPath.row]
        output?.languageDidSelect(language: item)
        continueBtn.setTitle(Localizable.Hello.Button.continue, for: .normal)
    }
}
