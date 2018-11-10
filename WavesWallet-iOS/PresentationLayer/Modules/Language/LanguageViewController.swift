//
//  EnterLanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol LanguageViewControllerDelegate: AnyObject {
    func languageViewChangedLanguage()
}

final class LanguageViewController: UIViewController {
    
    @IBOutlet private weak var gradientView: CustomGradientView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonConfirm: UIButton!
    private var gradientLayer: CAGradientLayer!
    
    private let languages = Language.list

    private lazy var selectedIndex: Int = {
        let current = Language.currentLanguage
        return self.languages.index(where: { $0.code == current.code }) ?? 0
    }()

    weak var delegate: LanguageViewControllerDelegate?
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.barTintColor = .white
        navigationItem.title = Localizable.Waves.Profile.Language.Navigation.title
        createBackButton()
        setupBigNavigationBar()
        setupLanguage()
    }
    
    // MARK: - Setups

    private func setupLanguage() {
        buttonConfirm.setTitle(Localizable.Waves.Enter.Button.Confirm.title, for: .normal)
    }
    
    // MARK: - Actions

    @IBAction func confirmTapped(_ sender: Any) {
        let language = languages[selectedIndex]
        Language.change(language)
        
        setupLanguage()
        delegate?.languageViewChangedLanguage()
    }

}

// MARK: UITableViewDataSource

extension LanguageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LanguageTableCell = tableView.dequeueAndRegisterCell()
        
        let item = languages[indexPath.row]
        
        cell.update(with: .init(icon: UIImage(named: item.icon), title: item.title, isOn: indexPath.row == selectedIndex))
        
        return cell
    }
    
}

// MARK: UITableViewDelegate

extension LanguageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        return LanguageTableCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedIndex = indexPath.row
        tableView.reloadData()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
