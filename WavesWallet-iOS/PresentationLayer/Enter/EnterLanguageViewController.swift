//
//  EnterLanguageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EnterLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonConfirm: UIButton!
    
    private let languages = Language.list

    private lazy var selectedIndex: Int = {
        let current = Language.currentLanguage
        return self.languages.index(where: { $0.code == current.code }) ?? 0
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLanguage()
        addBgBlueImage()
        self.buttonConfirm.alpha = 0
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupLanguage() {
        buttonConfirm.setTitle(Localizable.Enter.Button.Confirm.title, for: .normal)
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

        // TODO Moved code to app coordinator
        setupLanguage()
        let language = languages[indexPath.row]
        Language.change(language)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableCell", for: indexPath) as! LanguageTableCell
        
        let item = languages[indexPath.row]
        cell.labelTitle.text = item.title
        cell.iconLanguage.image = UIImage(named: item.icon)
        
        if indexPath.row == selectedIndex {
            cell.iconCheckmark.image = Images.on.image
        } else {
            cell.iconCheckmark.image = Images.off.image 
        }
        
        return cell
    }
}
