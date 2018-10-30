//
//  EnterStartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: Float = 2
    static let shadowOpacity: Float = 0.1
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowRadius: Float = 4
    static let shadowColor: UIColor = .black
    
    enum CollectionTopOffset: CGFloat {
        case small = 0
        case medium = 24
        case big = 64
    }
    
    enum ButtonTopOffset: CGFloat {
        case small = 24
        case big = 44
    }
    
}

protocol EnterStartViewControllerDelegate: AnyObject {
    func showSignInAccount()
    func showImportCoordinator()
    func showNewAccount()
    func showLanguageCoordinator()
}

final class EnterStartViewController: UIViewController, UICollectionViewDelegate {
    typealias Block = EnterStartTypes.Block

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var collectionTopOffsetConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createAccountButtonTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var importAccountView: UIView!
    @IBOutlet weak var signInView: UIView!
    
    @IBOutlet private weak var signInTitleLabel: UILabel!
    @IBOutlet private weak var signInDetailLabel: UILabel!
    @IBOutlet private weak var importAccountTitleLabel: UILabel!
    @IBOutlet private weak var importAccountDetailLabel: UILabel!
    @IBOutlet private weak var createNewAccountButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var currentPage: Int  = 0
    private let blocks: [Block] = [.blockchain,
                                   .wallet,
                                   .dex,
                                   .token]

    weak var delegate: EnterStartViewControllerDelegate?

    deinit {
        unsubscribe()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton()
        setupNavigationItem()
        
        subscribeLanguageNotification()
        setupLanguage()
        
        setupCollectionView()
        setupTopOffsetConstraint()
    }

    // MARK: - Setup
    
    private func setupCollectionView() {
        collectionView.register(EnterStartBlockCell.nib, forCellWithReuseIdentifier: EnterStartBlockCell.reuseIdentifier)
    }
    
    private func setupLanguage() {
        collectionView.reloadData()
    createNewAccountButton.setTitle(Localizable.Waves.Enter.Button.Createnewaccount.title, for: .normal)
        
        signInTitleLabel.text = Localizable.Waves.Enter.Button.Signin.title
        signInDetailLabel.text = Localizable.Waves.Enter.Button.Signin.detail
        
        importAccountTitleLabel.text = Localizable.Waves.Enter.Button.Importaccount.title
        importAccountDetailLabel.text = Localizable.Waves.Enter.Button.Importaccount.detail
        
        setupLanguageButton()
    }
    
    private func setupLanguageButton() {
        let language = Language.currentLanguage
        
        let item = UIBarButtonItem(title: language.code.uppercased(), style: .plain, target: self, action: #selector(changeLanguage(_:)))
        item.tintColor = .black
        
        navigationItem.rightBarButtonItem = item
    }
    
    private func setupNavigationItem() {
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        navigationItem.barTintColor = .black
        navigationItem.tintColor = .black
    }
    
    // MARK: - Layout
    
    private var layouted = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !layouted {
            layouted = true
            var maxHeight: CGFloat = 0
            
            for block in blocks {
                let height = EnterStartBlockCell.cellHeight(model: block, width: view.bounds.width)
                maxHeight = max(height, 0)
            }
            
            collectionViewHeightConstraint.constant = maxHeight
            
            let shadowOptions =
                ShadowOptions(offset: Constants.shadowOffset,
                              color: Constants.shadowColor,
                              opacity: Constants.shadowOpacity,
                              shadowRadius: Constants.shadowRadius,
                              shouldRasterize: true)
            
            signInView.setupShadow(options: shadowOptions)
            importAccountView.setupShadow(options: shadowOptions)
            importAccountView.cornerRadius = Constants.cornerRadius
            signInView.cornerRadius = Constants.cornerRadius
        }
        
    }

    // TODO: Remove Platform and add constants
    private func setupTopOffsetConstraint() {
        if Platform.isIphone5 {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.small.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.small.rawValue
        } else if Platform.isIphone7 {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.medium.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.big.rawValue
        } else {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.big.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.big.rawValue
        }
    }
    
    // MARK: - Notification

    private func subscribeLanguageNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage(_:)), name: .changedLanguage, object: nil)
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func changedLanguage(_ notification: NSNotification) {
        setupLanguage()
    }

    // MARK: - Actions

    @objc func changeLanguage(_ sender: Any) {
        delegate?.showLanguageCoordinator()
    }
    
    @IBAction func signIn(_ sender: Any) {
        delegate?.showSignInAccount()
    }
    
    @IBAction func importAccount(_ sender: Any) {
        delegate?.showImportCoordinator()
    }

    @IBAction func createNewAccountTapped(_ sender: Any) {
        delegate?.showNewAccount()
    }
    
}

extension EnterStartViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return blocks.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: EnterStartBlockCell = collectionView.dequeueReusableCell(withReuseIdentifier: EnterStartBlockCell.reuseIdentifier, for: indexPath) as! EnterStartBlockCell
        
        let block = blocks[indexPath.row] as Block
        cell.update(with: block)
        
        return cell
        
    }
    
}

extension EnterStartViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        pageControl.currentPage = page
    }
    
}

extension EnterStartViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: collectionView.bounds.width, height: collectionView.bounds.height)
        
    }
    
}
