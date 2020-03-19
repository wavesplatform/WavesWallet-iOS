//
//  LanguagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

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
    @IBOutlet private var continueBtn: UIButton!

    @IBOutlet private weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var gradientView: CustomGradientView!
    @IBOutlet private weak var whiteView: UIView!
    
    @IBOutlet private weak var continueButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var continueButtonRightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var safeAreaViewHeightConstraint: NSLayoutConstraint!
    
    private var languages: [Language] = Language.list

    private var chosenIndexPath: IndexPath?

    weak var output: HelloLanguagesModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.accessibilityIdentifier = AccessibilityIdentifiers.Hellolanguagesviewcontroller.rootView
        self.continueBtn.accessibilityIdentifier = AccessibilityIdentifiers.Hellolanguagesviewcontroller.continueBtn
        
        navigationItem.isNavigationBarHidden = true

        tableView.showsVerticalScrollIndicator = false
        continueBtn.alpha = 0
        gradientView.alpha = 0
        whiteView.alpha = 0
        setupConstraints()
    }

    private func setupConstraints() {
        
        if Platform.isIphone5 {
            continueButtonBottomConstraint.constant = 12
            continueButtonLeftConstraint.constant = 12
            continueButtonRightConstraint.constant = 12
            logoTopConstraint.constant = 44
            safeAreaViewHeightConstraint.constant = UIApplication.shared.statusBarFrame.height
        } else {
            continueButtonBottomConstraint.constant = 24
            continueButtonLeftConstraint.constant = 24
            continueButtonRightConstraint.constant = 24
            logoTopConstraint.constant = 44
            
            if Platform.isIphone7 {
                safeAreaViewHeightConstraint.constant = UIApplication.shared.statusBarFrame.height
            } else {
                safeAreaViewHeightConstraint.constant = 0
            }
        }
        
        let topInset = Constants.logoTop + logoHeightConstraint.constant + Constants.logoBottom
        let bottomInset = continueButtonBottomConstraint.constant +
            continueBtn.bounds.height +
            continueButtonBottomConstraint.constant
        
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    }
    
    // MARK: - Actions
    
    @IBAction private func continueWasPressed(_ sender: Any) {
        output?.userFinishedChangeLanguage()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        languages.count
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
            self.gradientView.alpha = 1.0
            self.whiteView.alpha = 1.0
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
