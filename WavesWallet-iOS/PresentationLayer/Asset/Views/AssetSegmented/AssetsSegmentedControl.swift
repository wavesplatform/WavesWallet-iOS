//
//  AssetsSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import UPCarouselFlowLayout

private enum Constants {
    static let spacing: CGFloat = 24
}

final class AssetsSegmentedControl: UIControl, NibOwnerLoadable {

    struct Asset {
        enum Kind {
            case fiat
            case wavesToken
            case spam
            case gateway
        }

        let name: String
        let kind: Kind
    }

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var detailLabel: UILabel!

    private var assets: [Asset] = [] {
        didSet {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.updateWithNewPage(self.currentPage)
            }
            collectionView.reloadData()
            CATransaction.commit()
        }
    }

    private(set) var currentPage: Int = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = backgroundColor
            self.collectionView.backgroundView = {
                let view = UIView()
                view.backgroundColor = backgroundColor
                return view
            }()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        assets = [Asset(name: "Waves", kind: .fiat),
                  Asset(name: "Test2", kind: .gateway),
                  Asset(name: "Test2", kind: .spam),
                  Asset(name: "Test2", kind: .wavesToken)]

        detailLabel.isHidden = true
        tickerView.update(with: TickerView.Model(text: "Test", style: .normal))
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: Constants.spacing)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 100)
    }

    func setCurrentPage(_ page: Int, animated: Bool = true) {
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0),
                                    at: .centeredHorizontally,
                                    animated: animated)
        updateWithNewPage(page)
    }
}

// MARK: Private method

fileprivate extension AssetsSegmentedControl {

    var currentPageByContentOffset: Int {
        return  Int(floor((collectionView.contentOffset.x - collectionPageSize.width / 2) / collectionPageSize.width) + 1)
    }

    var collectionPageSize: CGSize {
        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        }
        else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }

    func updateWithNewPage(_ newPage: Int) {

        if newPage == currentPage {
            return
        }
        currentPage = newPage
        let asset = assets[newPage]

        tickerView.isHidden = asset.kind != .spam
        detailLabel.isHidden = asset.kind == .spam
        switch asset.kind {
        case .fiat:
            detailLabel.text = Localizable.General.Ticker.Title.fiatmoney
        case .gateway:
            detailLabel.text = Localizable.General.Ticker.Title.cryptocurrency
        case .spam:
            tickerView.update(with: .init(text: Localizable.General.Ticker.Title.spam,
                                          style: .normal))
        case .wavesToken:
            detailLabel.text = Localizable.General.Ticker.Title.wavestoken
        }

        sendActions(for: .valueChanged)
    }
}

// MARK: UICollectionViewDataSource

extension AssetsSegmentedControl: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetsSegmentedCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)

        let asset = assets[indexPath.row]

        let isHiddenArrow = asset.kind != .fiat || asset.kind != .gateway

        let model = AssetsSegmentedCell.Model(icon: asset.name,
                                              isHiddenArrow: isHiddenArrow)
        cell.update(with: model)
        return cell
    }
}

//TODO: UICollectionViewDelegate

extension AssetsSegmentedControl: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setCurrentPage(indexPath.row)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPage(currentPageByContentOffset)
    }
}
