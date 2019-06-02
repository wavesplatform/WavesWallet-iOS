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
    static let contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0)
    static let searchBarTopDiff: CGFloat = 6
    
    enum Shadow {
        static let height: CGFloat = 4
        static let opacity: Float = 0.1
        static let radius: Float = 3
    }
}

final class WalletSearchViewController: UIViewController  {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonCancel: UIButton!
    @IBOutlet private weak var buttonCancelWidth: NSLayoutConstraint!
    @IBOutlet private weak var buttonCancelPosition: NSLayoutConstraint!
    @IBOutlet private weak var searchBarContainer: UIView!
    
    private var startPosition: CGFloat = 0
    
    var assets: [DomainLayer.DTO.SmartAssetBalance] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupButtonCancel()
        view.alpha = 0
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = Constants.contentInset
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {

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
        startPosition = fromStartPosition - Constants.searchBarTopDiff
        
        let startOffset = viewContainer.frame.origin.y
        viewContainer.frame.origin.y = startPosition 
        buttonCancelPosition.constant = 0
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.view.alpha = 1
            self.view.layoutIfNeeded()
            self.viewContainer.frame.origin.y = startOffset
        }) { (complete) in
            self.textFieldSearch.becomeFirstResponder()
        }
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
        
        let imageView = UIImageView(image: Images.search24Black.image)
        imageView.frame = Constants.searchIconFrame
        imageView.contentMode = .center
        textFieldSearch.leftView = imageView
        textFieldSearch.leftViewMode = .always
        textFieldSearch.placeholder = nil
        
        searchBarContainer.backgroundColor = .basic50
        searchBarContainer.layer.setupShadow(options: .init(offset: CGSize(width: 0, height: Constants.Shadow.height),
                                                            color: .black,
                                                            opacity: Constants.Shadow.opacity,
                                                            shadowRadius: Constants.Shadow.radius,
                                                            shouldRasterize: true))
    }
}

//MARK: - UITableViewDelegate
extension WalletSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletTableAssetsCell.cellHeight()
    }
}

//MARK: - UITableViewDataSource
extension WalletSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueAndRegisterCell() as WalletTableAssetsCell
        cell.update(with: assets[indexPath.row])
        return cell
    }
}
