//
//  LanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol LanguageViewControllerDelegate: AnyObject {
    func languageViewChangedLanguage()
}

final class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private var tableView: UITableView!
    private let languages = Language.list

    weak var delegate: LanguageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localizable.Profile.Language.Navigation.title
        navigationItem.barTintColor = .white
        createBackButton()
        setupBigNavigationBar()
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        Language.change(language)
        tableView.reloadData()
        delegate?.languageViewChangedLanguage()
//        navigationController?.popViewController(animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: LanguageTableCell = tableView.dequeueAndRegisterCell()
        let item = languages[indexPath.row]
        let isOn = Language.currentLanguage.code == item.code

        cell.update(with: .init(icon: UIImage(named: item.icon), title: item.title, isOn: isOn))
        
        return cell
    }
}
