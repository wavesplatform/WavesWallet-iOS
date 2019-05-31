//
//  WalletSearchViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let searchIconFrame: CGRect = .init(x: 0, y: 0, width: 36, height: 24)
    static let deltaButtonWidth: CGFloat = 16
}

final class WalletSearchViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonCancel: UIButton!
    @IBOutlet private weak var buttonCancelWidth: NSLayoutConstraint!
    @IBOutlet private weak var buttonCancelPosition: NSLayoutConstraint!
    
    private var startPosition: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupButtonCancel()
        view.alpha = 0
        textFieldSearch.becomeFirstResponder()
        tableView.keyboardDismissMode = .onDrag
    }
    
    
    @IBAction private func cancelTapped(_ sender: Any) {

        textFieldSearch.resignFirstResponder()
        buttonCancelPosition.constant = -buttonCancelWidth.constant
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.viewContainer.frame.origin.y = self.startPosition
            self.view.layoutIfNeeded()
            self.view.alpha = 0
        }) { (complete) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func showWithAnimation(fromStartPosition: CGFloat) {
        
        startPosition = fromStartPosition
        view.alpha = 1        
        let startOffset = viewContainer.frame.origin.y
        viewContainer.frame.origin.y = fromStartPosition
        buttonCancelPosition.constant = 0
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.view.layoutIfNeeded()
            self.viewContainer.frame.origin.y = startOffset
        })
    }
}

//MARK: - UI
private extension WalletSearchViewController {
    
    func setupButtonCancel() {
        let buttonTitle = Localizable.Waves.Walletsearch.Button.cancel
        buttonCancel.setTitle(buttonTitle, for: .normal)
        
        guard let font = buttonCancel.titleLabel?.font else { return }
        buttonCancelWidth.constant = buttonTitle.maxWidth(font: font) + Constants.deltaButtonWidth
        buttonCancelPosition.constant = -buttonCancelWidth.constant
    }
    
    func setupSearchBar() {
        
        let imageView = UIImageView(image: Images.search24Basic500.image)
        imageView.frame = Constants.searchIconFrame
        imageView.contentMode = .center
        textFieldSearch.leftView = imageView
        textFieldSearch.leftViewMode = .always
        textFieldSearch.attributedPlaceholder = NSAttributedString.init(string: Localizable.Waves.Wallet.Label.search, attributes: [NSAttributedString.Key.foregroundColor : UIColor.basic500])
    }
}

//MARK: - UITableViewDelegate
extension WalletSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
}

//MARK: - UITableViewDataSource
extension WalletSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
}
