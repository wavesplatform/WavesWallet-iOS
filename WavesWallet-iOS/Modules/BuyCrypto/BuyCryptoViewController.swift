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

    private let errorView = GlobalErrorView()

    private var presenterOutput: BuyCryptoPresenterOutput?

    private var fiatAssets: [BuyCryptoPresenter.AssetViewModel] = []
    private var cryptoAssets: [BuyCryptoPresenter.AssetViewModel] = []

    private let didSelectFiatItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didSelectCryptoItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didChangeFiatAmount = PublishRelay<String?>()
    private let didTapBuy = PublishRelay<Void>()
    private let didTapURL = PublishRelay<URL>()

    private let didTapRetry = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    
    private var lastTouchedCryptoAssetByIndexPath: IndexPath?
    private var lastTouchedFiatAssetByIndexPath: IndexPath?

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

            scrollView.showsVerticalScrollIndicator = false
            scrollView.delegate = self
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
        fiatAmountTextField.text.distinctUntilChanged().bind(to: didChangeFiatAmount).disposed(by: disposeBag)

        buyButton.didTouchButton = { [weak self] in
            self?.didTapBuy.accept(Void())
        }
        
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
        infoTextView.text = nil
        infoTextView.isEditable = false
        infoTextView.isSelectable = false
        infoTextView.isScrollEnabled = false
        infoTextView.backgroundColor = .basic50
        infoTextView.keyboardType = .numberPad
        infoTextView.delegate = self
    }
}

// MARK: - BindableView

extension BuyCryptoViewController: BindableView {
    func getOutput() -> BuyCryptoViewOutput {
        let viewWillAppear = rx.viewWillAppear.mapAsVoid()
        
        let didSelectFiatItem = ControlEvent(events: self.didSelectFiatItem.throttle(RxTimeInterval.seconds(2),
                                                                                     latest: true,
                                                                                     scheduler: MainScheduler.instance))
        let didSelectCryptoItem = ControlEvent(events: self.didSelectCryptoItem.throttle(RxTimeInterval.seconds(2),
                                                                                         latest: true,
                                                                                         scheduler: MainScheduler.instance))
        
        return BuyCryptoViewOutput(didSelectFiatItem: didSelectFiatItem,
                                   didSelectCryptoItem: didSelectCryptoItem,
                                   didChangeFiatAmount: didChangeFiatAmount.asControlEvent(),
                                   didTapBuy: didTapBuy.asControlEvent(),
                                   viewWillAppear: ControlEvent<Void>(events: viewWillAppear),
                                   didTapRetry: didTapRetry.asControlEvent(),
                                   didTapURL: didTapURL.asControlEvent())
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

        bindErrors(initialError: input.initialError,
                   showSnackBarError: input.showSnackBarError,
                   validationError: input.validationError)

        bindCarouselItems(fiatItems: input.fiatItems, cryptoItems: input.cryptoItems)

        input.fiatTitle.drive(spentLabel.rx.text).disposed(by: disposeBag)
        input.cryptoTitle.drive(buyLabel.rx.text).disposed(by: disposeBag)

        input.buyButtonModel
            .drive(onNext: { [weak self] model in
                self?.buyButton.update(with: model)
            })
            .disposed(by: disposeBag)

        input.detailsInfo
            .drive(onNext: { [weak self] in self?.bindExchangeMessage(message: $0) })
            .disposed(by: disposeBag)
    }

    private func bindErrors(initialError: Signal<String>, showSnackBarError: Signal<String>, validationError: Signal<String?>) {
        initialError
            .emit(onNext: { [weak self] errorMessage in self?.showInitialError(errorMessage: errorMessage) })
            .disposed(by: disposeBag)

        showSnackBarError
            .emit(onNext: { [weak self] errorMessage in
                guard let sself = self else { return }
                var keySnackBar = ""
                keySnackBar = sself.showErrorSnack(title: errorMessage,
                                                   didTap: { [weak self] in
                                                       self?.hideSnack(key: keySnackBar)
                                                       self?.didTapRetry.accept(Void())
                })
            })
            .disposed(by: disposeBag)

        validationError
            .emit(onNext: { [weak self] errorMessage in self?.fiatAmountTextField.setError(errorMessage) })
            .disposed(by: disposeBag)
    }

    private func bindCarouselItems(fiatItems: Driver<[BuyCryptoPresenter.AssetViewModel]>,
                                   cryptoItems: Driver<[BuyCryptoPresenter.AssetViewModel]>) {
        fiatItems.drive(onNext: { [weak self] assets in
            self?.fiatAssets = assets
            self?.fiatCollectionView.reloadData()

            if let selectedFiat = assets.first {
                self?.didSelectFiatItem.accept(selectedFiat)
            }
        }).disposed(by: disposeBag)

        cryptoItems.drive(onNext: { [weak self] assets in
            self?.cryptoAssets = assets
            self?.cryptoCollectionView.reloadData()

            if let selectedCrypto = assets.first {
                self?.didSelectCryptoItem.accept(selectedCrypto)
            }
        }).disposed(by: disposeBag)
    }

    private func bindExchangeMessage(message: BuyCryptoPresenter.ExchangeMessage) {
        let attributeString = NSMutableAttributedString(string: message.message)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: UIColor.basic500,
                                     range: attributeString.mutableString.range(of: message.message))
        attributeString.addAttribute(NSAttributedString.Key.link,
                                     value: message.link,
                                     range: attributeString.mutableString.range(of: message.linkWord))
        infoTextView.attributedText = attributeString
        infoTextView.layoutIfNeeded()
    }

    private func showInitialError(errorMessage _: String) {
        let model = GlobalErrorView.Model(kind: .serverError)
        view.addStretchToBounds(errorView)
        errorView.update(with: model)

        errorView.retryDidTap = { [weak self] in
            self?.didTapRetry.accept(Void())
            self?.errorView.removeFromSuperview()
        }
    }

    private func hideNavigationTitleIfNeeded(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        let frame = spentLabel.frame

        // Выщитываем процент сдвига spentLabel
        var percent = offset / frame.height
        percent = max(percent, 0)
        percent = min(percent, 1)

        if percent == 1 {
            navigationItem.title = spentLabel.text
        } else {
            navigationItem.title = ""
        }

        UIView.animate(withDuration: 0.38, delay: 0, options: [.curveEaseInOut], animations: {
            if percent == 1 {
                self.navigationItem
                    .titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(1)]
                self.spentLabel.alpha = 0
            } else {
                self.navigationItem
                    .titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0)]
                self.spentLabel.alpha = 1
            }
        }) { _ in }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        if collectionView === fiatCollectionView {
            let fiatAsset = fiatAssets[indexPath.item]
            didSelectFiatItem.accept(fiatAsset)
        } else {
            let cryptoAsset = cryptoAssets[indexPath.item]
            didSelectCryptoItem.accept(cryptoAsset)
        }
    }

    
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
        } else if scrollView === self.scrollView {
            hideNavigationTitleIfNeeded(scrollView: scrollView)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === self.scrollView {
            if decelerate {
                return
            }
            hideNavigationTitleIfNeeded(scrollView: scrollView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        if scrollView === fiatCollectionView {
            let currentItemOffset = fiatCollectionView.contentInset.left + fiatCollectionView.contentOffset.x

            let centerFiatCollectionViewPoint = CGPoint(x: currentItemOffset, y: fiatCollectionView.bounds.midY)
            if let indexPath = fiatCollectionView.indexPathForItem(at: centerFiatCollectionViewPoint),
                lastTouchedFiatAssetByIndexPath != indexPath {
                ImpactFeedbackGenerator.impactOccurred()
                lastTouchedFiatAssetByIndexPath = indexPath
            }
        } else if scrollView === cryptoCollectionView {
            let currentItemOffset = cryptoCollectionView.contentInset.left + cryptoCollectionView.contentOffset.x
            let centerCryptoCollectionViewPoint = CGPoint(x: currentItemOffset, y: cryptoCollectionView.bounds.midY)
            if let indexPath = cryptoCollectionView.indexPathForItem(at: centerCryptoCollectionViewPoint),
                lastTouchedCryptoAssetByIndexPath != indexPath {
                ImpactFeedbackGenerator.impactOccurred()
                lastTouchedCryptoAssetByIndexPath = indexPath
            }
        } else if scrollView === self.scrollView {
            hideNavigationTitleIfNeeded(scrollView: scrollView)
        }
    }
}

extension BuyCryptoViewController: UITextViewDelegate {
    func textView(_: UITextView,
                  shouldInteractWith url: URL,
                  in _: NSRange,
                  interaction _: UITextItemInteraction) -> Bool {
        didTapURL.accept(url)
        return false
    }
}

// MARK: - StoryboardInstantiatable

extension BuyCryptoViewController: StoryboardInstantiatable {}
