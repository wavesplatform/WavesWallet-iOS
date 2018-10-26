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
        let cell: LanguageTableCell = tableView.dequeueAndRegisterCell()

        let item = languages[indexPath.row]
        
        var isOn = false
        if let index = chosenIndexPath, index == indexPath {
            isOn = true
        }
        
        cell.update(with: .init(icon: UIImage(named: item.icon), title: item.title, isOn: isOn))

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
        continueBtn.setTitle(Localizable.Waves.Hello.Button.continue, for: .normal)
    }
}
