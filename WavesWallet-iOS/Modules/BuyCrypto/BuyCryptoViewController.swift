//
//  BuyCryptoViewController.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import Extensions
import Kingfisher
import RxCocoa
import RxSwift
import StandartTools
import UIKit
import UITools
import WavesUIKit

final class BuyCryptoViewController: UIViewController, BuyCryptoViewControllable {
    var interactor: BuyCryptoInteractable?

    private let buyCryptoSkeletonView = BuyCryptoSkeletonView.loadFromNib()

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollContainerView: UIView!
    @IBOutlet private weak var spentLabel: UILabel!
    @IBOutlet private weak var fiatCollectionView: UICollectionView!
    @IBOutlet private weak var fiatZoomLayout: ZoomFlowLayout!
    @IBOutlet private weak var fiatAmountTextField: RoundedTextField!
    @IBOutlet private weak var fiatSeparatorImageView: UIImageView!
    @IBOutlet private weak var buyLabel: UILabel!
    @IBOutlet private weak var cryptoCollectionView: UICollectionView!
    @IBOutlet private weak var cryptoZoomLayout: ZoomFlowLayout!
    @IBOutlet private weak var buyButton: BlueButton!
    @IBOutlet private weak var infoTextView: UITextView!

    private var presenterOutput: BuyCryptoPresenterOutput?

    private var fiatAssets: [BuyCryptoPresenter.AssetViewModel] = []
    private var cryptoAssets: [BuyCryptoPresenter.AssetViewModel] = []

    private let didSelectFiatItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didSelectCryptoItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didChangeFiatAmount = PublishRelay<String?>()
    private let didTapBuy = PublishRelay<Void>()

    private let didTapRetry = PublishRelay<Void>()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        bindIfNeeded()
    }

    private func initialSetup() {
        do {
            createBackButton()
            setupBigNavigationBar()
            
            navigationItem.largeTitleDisplayMode = .never

            view.backgroundColor = .basic50
            scrollContainerView.backgroundColor = .basic50
        }

        do {
            fiatSeparatorImageView.contentMode = .scaleAspectFill
            fiatSeparatorImageView.image = Images.separateLineWithArrow.image
        }
        
        setupFiatCollectionView()
        setupCryptoCollectionView()
        fiatAmountTextField.setPlaceholder(Localizable.Waves.Buycrypto.amountPlaceholder)
        fiatAmountTextField
            .text
            .subscribe(onNext: { [weak self] in
                self?.didChangeFiatAmount.accept($0)
            })
            .disposed(by: disposeBag)
        setupInfoTextView()
    }

    private func setupFiatCollectionView() {
        fiatZoomLayout.minimumLineSpacing = 24
        fiatZoomLayout.minimumInteritemSpacing = 0
        fiatZoomLayout.itemSize = CGSize(width: 48, height: 48)
        fiatZoomLayout.invalidateLayout()
        fiatCollectionView.showsHorizontalScrollIndicator = false
        fiatCollectionView.backgroundColor = .basic50
        fiatCollectionView.registerCell(type: ImageViewCollectionViewCell.self)
        fiatCollectionView.dataSource = self
        fiatCollectionView.delegate = self
    }

    private func setupCryptoCollectionView() {
        fiatZoomLayout.minimumLineSpacing = 24
        cryptoZoomLayout.minimumInteritemSpacing = 0
        cryptoZoomLayout.itemSize = CGSize(width: 48, height: 48)
        cryptoZoomLayout.invalidateLayout()
        cryptoCollectionView.showsHorizontalScrollIndicator = false
        cryptoCollectionView.backgroundColor = .basic50
        cryptoCollectionView.registerCell(type: ImageViewCollectionViewCell.self)
        cryptoCollectionView.dataSource = self
        cryptoCollectionView.delegate = self
    }

    private func setupInfoTextView() {
        let infoTextViewBorder = CAShapeLayer()
        infoTextViewBorder.strokeColor = UIColor.basic300.cgColor
        infoTextViewBorder.lineDashPattern = [4, 4]
        infoTextViewBorder.frame = infoTextView.bounds
        infoTextViewBorder.fillColor = nil
        infoTextViewBorder.path = UIBezierPath(rect: infoTextView.bounds).cgPath
        infoTextView.layer.addSublayer(infoTextViewBorder)

        infoTextView.isEditable = false
        infoTextView.isSelectable = false
        infoTextView.isScrollEnabled = false
        infoTextView.backgroundColor = .basic50
    }
}

// MARK: - BindableView

extension BuyCryptoViewController: BindableView {
    func getOutput() -> BuyCryptoViewOutput {
        let viewWillAppear = rx.viewWillAppear.mapAsVoid()

        return BuyCryptoViewOutput(didSelectFiatItem: didSelectFiatItem.asControlEvent(),
                                   didSelectCryptoItem: didSelectCryptoItem.asControlEvent(),
                                   didChangeFiatAmount: didChangeFiatAmount.asControlEvent(),
                                   didTapBuy: didTapBuy.asControlEvent(),
                                   viewWillAppear: ControlEvent<Void>(events: viewWillAppear),
                                   didTapRetry: didTapRetry.asControlEvent())
    }

    func bindWith(_ input: BuyCryptoPresenterOutput) {
        presenterOutput = input
        bindIfNeeded()
    }

    private func bindIfNeeded() {
        guard let input = presenterOutput, isViewLoaded else { return }

        input.contentVisible.drive(onNext: { [weak self] isVisible in
            self?.scrollContainerView.isVisible = isVisible
        }).disposed(by: disposeBag)

        input.isLoadingIndicator.drive(onNext: { [weak self] isLoading in
            guard let sself = self else { return }
            if isLoading {
                sself.view.addStretchToBounds(sself.buyCryptoSkeletonView)
                sself.buyCryptoSkeletonView.startAnimation(to: .right)
            } else {
                sself.buyCryptoSkeletonView.stopAnimation()
                sself.buyCryptoSkeletonView.removeFromSuperview()
            }
        }).disposed(by: disposeBag)

        input.fiatItems.drive(onNext: { [weak self] assets in
            self?.fiatAssets = assets
            self?.fiatCollectionView.reloadData()

            if let selectedFiat = assets.first {
                self?.didSelectFiatItem.accept(selectedFiat)
            }
        }).disposed(by: disposeBag)

        input.cryptoItems.drive(onNext: { [weak self] assets in
            self?.cryptoAssets = assets
            self?.cryptoCollectionView.reloadData()

            if let selectedCrypto = assets.first {
                self?.didSelectCryptoItem.accept(selectedCrypto)
            }
        }).disposed(by: disposeBag)

        input.fiatTitle.drive(spentLabel.rx.text).disposed(by: disposeBag)
        input.cryptoTitle.drive(buyLabel.rx.text).disposed(by: disposeBag)

        input.buyButtonModel.drive(onNext: { [weak self] titledBool in
            let buttonStatus = titledBool.isOn ? BlueButton.Model.Status.active : BlueButton.Model.Status.disabled
            let buttonModel = BlueButton.Model(title: titledBool.title, status: buttonStatus)
            self?.buyButton.update(with: buttonModel)
        }).disposed(by: disposeBag)
        
        input.validationError.emit(onNext: { [weak self] errorMessage in
            self?.fiatAmountTextField.setError(errorMessage)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension BuyCryptoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if collectionView === fiatCollectionView {
            return fiatAssets.count
        } else if collectionView == cryptoCollectionView {
            return cryptoAssets.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageViewCollectionViewCell = collectionView.dequeueCellForIndexPath(indexPath: indexPath)

        if collectionView === fiatCollectionView {
            let asset = fiatAssets[indexPath.row]
            AssetLogo
                .logo(icon: asset.icon, style: asset.iconStyle)
                .subscribe(onNext: { [weak cell] in cell?.view.image = $0 })
                .disposed(by: disposeBag)
        } else if collectionView === cryptoCollectionView {
            let asset = cryptoAssets[indexPath.row]
            AssetLogo
                .logo(icon: asset.icon, style: asset.iconStyle)
                .subscribe(onNext: { [weak cell] in cell?.view.image = $0 })
                .disposed(by: disposeBag)
        } else {
            assertionFailure("Unknow collection view in BuyCryptoViewController \(#function)")
        }

        return cell
    }
}

extension BuyCryptoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === fiatCollectionView {
            let currentItemOffset = fiatCollectionView.contentInset.left + fiatCollectionView.contentOffset.x

            let centerFiatCollectionViewPoint = CGPoint(x: currentItemOffset, y: fiatCollectionView.bounds.midY)
            if let indexPath = fiatCollectionView.indexPathForItem(at: centerFiatCollectionViewPoint) {
                let fiatAsset = fiatAssets[indexPath.item]
                didSelectFiatItem.accept(fiatAsset)
            }
        } else if scrollView === cryptoCollectionView {
            let currentItemOffset = cryptoCollectionView.contentInset.left + cryptoCollectionView.contentOffset.x
            let centerCryptoCollectionViewPoint = CGPoint(x: currentItemOffset, y: cryptoCollectionView.bounds.midY)
            if let indexPath = cryptoCollectionView.indexPathForItem(at: centerCryptoCollectionViewPoint) {
                let cryptoAsset = cryptoAssets[indexPath.item]
                didSelectCryptoItem.accept(cryptoAsset)
            }
        } else {
            assertionFailure("Unknow collection view in BuyCryptoViewController \(#function)")
            // impossible case
        }
    }
}

// MARK: - StoryboardInstantiatable

extension BuyCryptoViewController: StoryboardInstantiatable {}
