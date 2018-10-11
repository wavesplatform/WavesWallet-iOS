//
//  LanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private var tableView: UITableView!

    private let languages = Language.list

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        navigationController?.navigationBar.barTintColor = .white
        title = "Language"
    }

    // MARK: - UITableView

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

        let cell: LanguageTableCell = tableView.dequeueAndRegisterCell()

        let item = languages[indexPath.row]
        cell.update(with: .init(icon: UIImage(named: item.icon), title: item.title, isOn: indexPath.row == 0))
        
        return cell
    }
}
