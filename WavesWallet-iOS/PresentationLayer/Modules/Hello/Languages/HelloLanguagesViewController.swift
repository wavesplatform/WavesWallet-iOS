//
//  LanguagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let logoTop: CGFloat = 44
    static let logoBottom: CGFloat = 44
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

    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var continueButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButtonRightConstraint: NSLayoutConstraint!
    
    
    private var languages: [Language] = {
        return Language.list
    }()

    private var chosenIndexPath: IndexPath?

    weak var output: HelloLanguagesModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.showsVerticalScrollIndicator = false
        continueBtn.alpha = 0
        setupConstraints()
    }

    private func setupConstraints() {
        
        if Platform.isIphone5 {
            continueButtonBottomConstraint.constant = 12
            continueButtonLeftConstraint.constant = 12
            continueButtonRightConstraint.constant = 12
            logoTopConstraint.constant = 44
        } else {
            continueButtonBottomConstraint.constant = 24
            continueButtonLeftConstraint.constant = 16
            continueButtonRightConstraint.constant = 16
            logoTopConstraint.constant = 44
        }
        
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = UIEdgeInsets(top: Constants.logoTop + logoHeightConstraint.constant + Constants.logoBottom, left: 0, bottom: continueButtonBottomConstraint.constant + continueBtn.bounds.height + continueButtonBottomConstraint.constant, right: 0)
    }
    
    // MARK: - Actions
    
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

        UIView.animate(withDuration: Constants.animationDuration) {
            self.continueBtn.alpha = 1.0
        }

        let item = languages[indexPath.row]
        output?.languageDidSelect(language: item)
        continueBtn.setTitle(Localizable.Waves.Hello.Button.continue, for: .normal)
    }
    
}

extension HelloLanguagesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = -scrollView.contentOffset.y - scrollView.contentInset.top
        logoTopConstraint.constant = y + Constants.logoTop
        
    }
    
}
