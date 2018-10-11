//
//  EnterLanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EnterLanguageViewController: UIViewController {
    
    @IBOutlet weak private var gradientView: CustomGradientView!
    private var gradientLayer: CAGradientLayer!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonConfirm: UIButton!
    
    private let languages = Language.list

    private lazy var selectedIndex: Int = {
        let current = Language.currentLanguage
        return self.languages.index(where: { $0.code == current.code }) ?? 0
    }()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLanguage()
    }
    
    // MARK: - Setups

    private func setupLanguage() {
        buttonConfirm.setTitle(Localizable.Enter.Button.Confirm.title, for: .normal)
    }
    
    // MARK: - Actions

    @IBAction func confirmTapped(_ sender: Any) {
        let language = languages[selectedIndex]
        Language.change(language)
        
        setupLanguage()
        dismissController()
    }

}

extension EnterLanguageViewController: UITableViewDataSource {
    
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

extension EnterLanguageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return LanguageTableCell.cellHeight()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        tableView.reloadData()
 
    }
    
}

extension EnterLanguageViewController {
 
    func dismissController() {
        if let parent = self.parent as? PopupViewController {
            parent.dismissPopup()
        }
    }
    
}
