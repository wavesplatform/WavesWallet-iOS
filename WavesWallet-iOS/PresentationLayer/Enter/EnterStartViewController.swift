//
//  EnterStartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import SwipeView

private enum Constants {
    static let layoutSpacing: CGFloat = 24
}

final class EnterStartCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
}

fileprivate enum Block {
    case blockchain
    case wallet
    case exchange
    case token
}

fileprivate extension Block {

    var image: UIImage {
        switch self {
        case .blockchain:
            return Images.userimgBlockchain80White.image
        case .wallet:
            return Images.userimgWallet80White.image
        case .exchange:
            return Images.userimgDex80White.image
        case .token:
            return Images.userimgToken80White.image
        }
    }

    var title: String {
        switch self {
        case .blockchain:
            return Localizable.Enter.Block.Blockchain.title
        case .wallet:
            return Localizable.Enter.Block.Wallet.title
        case .exchange:
            return Localizable.Enter.Block.Exchange.title
        case .token:
            return Localizable.Enter.Block.Token.title
        }
    }

    var text: String {
        switch self {
        case .blockchain:
            return Localizable.Enter.Block.Blockchain.text
        case .wallet:
            return Localizable.Enter.Block.Wallet.text
        case .exchange:
            return Localizable.Enter.Block.Exchange.text
        case .token:
            return Localizable.Enter.Block.Token.text
        }
    }
}

protocol EnterStartViewControllerDelegate: AnyObject {
    func showSignInAccount()
    func showImportCoordinator()
    func showNewAccount()
}

final class EnterStartViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var collectionTopOffset: NSLayoutConstraint!    
    @IBOutlet private weak var signInTitleLabel: UILabel!
    @IBOutlet private weak var signInDetailLabel: UILabel!
    @IBOutlet private weak var importAccountTitleLabel: UILabel!
    @IBOutlet private weak var importAccountDetailLabel: UILabel!
    @IBOutlet private weak var createNewAccountButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!

    private var currentPage: Int  = 0
    private let blocks: [Block] = [.blockchain,
                                   .wallet,
                                   .exchange,
                                   .token]

    weak var delegate: EnterStartViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton(isWhite: true)
        setupLanguage()
        addBgBlueImage()
        
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: Constants.layoutSpacing)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage(_:)), name: .changedLanguage, object: nil)
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        navigationItem.barTintColor = .white
        navigationItem.tintColor = .white
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupLanguage() {
        collectionView.reloadData()

        let block = blocks[currentPage]
        titleLabel.text = block.title
        detailLabel.text = block.text

        createNewAccountButton.setTitle(Localizable.Enter.Button.Createnewaccount.title, for: .normal)

        signInTitleLabel.text = Localizable.Enter.Button.Signin.title
        signInDetailLabel.text = Localizable.Enter.Button.Signin.detail
        importAccountTitleLabel.text = Localizable.Enter.Button.Importaccount.title
        importAccountDetailLabel.text = Localizable.Enter.Button.Importaccount.detail

        let language = Language.currentLanguage
        let item = UIBarButtonItem(title: language.code.uppercased(), style: .plain, target: self, action: #selector(changeLanguage(_:)))
        item.tintColor = .white
         navigationItem.rightBarButtonItem = item
    }

    // MARK: Notification Handler

    @objc private  func changedLanguage(_ notification: NSNotification) {
        setupLanguage()
    }

    // MARK: Action methods

    @IBAction func changeLanguage(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EnterLanguageViewController") as! EnterLanguageViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func signInAccount(_ sender: Any) {        
        delegate?.showSignInAccount()
    }

    @IBAction func importAccount(_ sender: Any) {
        delegate?.showImportCoordinator()
    }

    @IBAction func createNewAccountTapped(_ sender: Any) {
        delegate?.showNewAccount()
    }

    //MARK: - UICollectionView
    
    fileprivate var collectionPageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnterStartCollectionCell", for: indexPath) as! EnterStartCollectionCell

        let block = blocks[indexPath.row]
        cell.imageIcon.image = block.image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row != currentPage {
            currentPage = indexPath.row
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            let block = blocks[indexPath.row]
            titleLabel.text = block.title
            detailLabel.text = block.text
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let newPage = Int(floor((scrollView.contentOffset.x - collectionPageSize.width / 2) / collectionPageSize.width) + 1)
            if currentPage != newPage {
                currentPage = newPage
                let block = blocks[currentPage]
                titleLabel.text = block.title
                detailLabel.text = block.text
            }
        }
    }
}
