//
//  EnterStartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    enum CollectionTopOffset: CGFloat {
        case small = 0
        case medium = 24
        case big = 64
    }

    enum ButtonTopOffset: CGFloat {
        case small = 14
        case big = 44
    }

    enum PageControlTopOffset: CGFloat {
        case small = 2
        case big = 24
    }
}

protocol EnterStartViewControllerDelegate: AnyObject {
    func showSignInAccount()
    func showImportCoordinator()
    func showNewAccount()
    func showLanguageCoordinator()
    func showDebug()
}

final class EnterStartViewController: UIViewController, UICollectionViewDelegate {
    typealias Block = EnterStartTypes.Block

    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var collectionTopOffsetConstraint: NSLayoutConstraint!

    @IBOutlet private weak var createAccountButtonTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var pageControlTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var importAccountView: UIView!
    @IBOutlet private weak var signInView: UIView!

    @IBOutlet private weak var signInTitleLabel: UILabel!
    @IBOutlet private weak var signInDetailLabel: UILabel!
    @IBOutlet private weak var importAccountTitleLabel: UILabel!
    @IBOutlet private weak var importAccountDetailLabel: UILabel!
    @IBOutlet private weak var createNewAccountButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet private weak var orLabel: UILabel!

    private var currentPage = 0
    private let blocks: [Block] = [.blockchain, .wallet, .dex]

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handlerTapGesture(gesture:)))
        gesture.numberOfTapsRequired = 5
        return gesture
    }()

    weak var delegate: EnterStartViewControllerDelegate?

    deinit {
        unsubscribe()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()

        subscribeLanguageNotification()
        setupLanguage()

        setupCollectionView()
        setupTopOffsetConstraint()

        collectionView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.register(EnterStartBlockCell.nib, forCellWithReuseIdentifier: EnterStartBlockCell.reuseIdentifier)
    }

    private func setupLanguage() {
        collectionView.reloadData()
        createNewAccountButton.setTitle(Localizable.Waves.Enter.Button.Createnewaccount.title, for: .normal)

        orLabel.text = Localizable.Waves.Enter.Label.or
        signInTitleLabel.text = Localizable.Waves.Enter.Button.Signin.title
        signInDetailLabel.text = Localizable.Waves.Enter.Button.Signin.detail

        importAccountTitleLabel.text = Localizable.Waves.Enter.Button.Importaccount.title
        importAccountDetailLabel.text = Localizable.Waves.Enter.Button.Importaccount.detail

        setupLanguageButton()
    }

    private func setupLanguageButton() {
        let language = Language.currentLanguage
        let code = language.titleCode ?? language.code
        let title = code.uppercased()
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(changeLanguage(_:)))
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

            signInView.addTableCellShadowStyle()
            importAccountView.addTableCellShadowStyle()
        }
    }

    private func setupTopOffsetConstraint() {
        if Platform.isIphone5 {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.small.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.small.rawValue
            pageControlTopConstraint.constant = Constants.PageControlTopOffset.small.rawValue
        } else if Platform.isIphone7 {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.medium.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.big.rawValue
            pageControlTopConstraint.constant = Constants.PageControlTopOffset.big.rawValue
        } else {
            collectionTopOffsetConstraint.constant = Constants.CollectionTopOffset.big.rawValue
            createAccountButtonTopConstraint.constant = Constants.ButtonTopOffset.big.rawValue
            pageControlTopConstraint.constant = Constants.PageControlTopOffset.big.rawValue
        }
    }

    // MARK: - Notification

    private func subscribeLanguageNotification() {
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(changedLanguage(_:)), name: .changedLanguage, object: nil)
    }

    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func changedLanguage(_: NSNotification) {
        setupLanguage()
    }

    // MARK: - Actions

    @objc func changeLanguage(_: Any) {
        delegate?.showLanguageCoordinator()
    }

    @objc func handlerTapGesture(gesture _: UITapGestureRecognizer) {
        delegate?.showDebug()
    }

    @IBAction private func signIn(_: Any) {
        delegate?.showSignInAccount()
    }

    @IBAction private func importAccount(_: Any) {
        delegate?.showImportCoordinator()
    }

    @IBAction private func createNewAccountTapped(_: Any) {
        delegate?.showNewAccount()
    }
}

extension EnterStartViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        blocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EnterStartBlockCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: EnterStartBlockCell.reuseIdentifier, for: indexPath) as! EnterStartBlockCell

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
    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
