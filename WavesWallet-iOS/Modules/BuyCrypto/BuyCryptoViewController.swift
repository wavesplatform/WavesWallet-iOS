// 
//  BuyCryptoViewController.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import StandartTools
import AppTools
import RxCocoa
import Extensions
import RxSwift
import UIKit
import UITools
import Kingfisher
import WavesUIKit

final class BuyCryptoViewController: UIViewController, BuyCryptoViewControllable {
    var interactor: BuyCryptoInteractable?

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
    
    private var fiatAssets: [BuyCryptoPresenter.AssetViewModel] = []
    private var cryptoAssets: [BuyCryptoPresenter.AssetViewModel] = []
    
    private let didSelectFiatItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didSelectCryptoItem = PublishRelay<BuyCryptoPresenter.AssetViewModel>()
    private let didChangeFiatAmount = PublishRelay<String>()
    private let didTapBuy = PublishRelay<Void>()
    
    private let didTapRetry = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    private func initialSetup() {
        navigationItem.largeTitleDisplayMode = .never
        
        scrollContainerView.backgroundColor = .basic50
        
        setupFiatCollectionView()
        setupCryptoCollectionView()
        
        do {
            fiatSeparatorImageView.contentMode = .scaleAspectFill
            fiatSeparatorImageView.image = Images.separateLineWithArrow.image
        }

        fiatAmountTextField.setPlaceholder(Localizable.Waves.Buycrypto.amountPlaceholder)

        do {
            infoTextView.isScrollEnabled = false
            infoTextView.layer.borderColor = UIColor.basic300.cgColor
            infoTextView.layer.borderWidth = 1
        }
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
        input.fiatItems
            .drive(onNext: { [weak self] assets in
                self?.fiatAssets = assets
                self?.fiatCollectionView.reloadData()
                
                if let selectedFiat = assets.first {
                    self?.didSelectFiatItem.accept(selectedFiat)
                }
            })
            .disposed(by: disposeBag)
        
        input.cryptoItems
            .drive(onNext: { [weak self] assets in
                self?.cryptoAssets = assets
                self?.cryptoCollectionView.reloadData()
                
                if let selectedCrypto = assets.first {
                    self?.didSelectCryptoItem.accept(selectedCrypto)
                }
            })
            .disposed(by: disposeBag)
        
//        input.buyButtonEnabled
//            .drive(onNext: { [weak self] isEnabled in
//                //self?.buyButton.update(with: BlueButton.Model(title: <#T##String#>, status: <#T##BlueButton.Model.Status#>))
//            })
//            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension BuyCryptoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            assertionFailure("Unknow collection view in BuyCryptoViewController")
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
            
//            fiatCollectionView.visibleCells.forEach {
////                print("frame = \($0.frame)")
////                print("frame contains point \($0.frame.contains(centerFiatCollectionViewPoint))")
//                if $0.frame.contains(centerFiatCollectionViewPoint) {
//                    print(fiatCollectionView.indexPath(for: $0))
//                }
//            }
        }
    }
}

// MARK: - StoryboardInstantiatable

extension BuyCryptoViewController: StoryboardInstantiatable {}
