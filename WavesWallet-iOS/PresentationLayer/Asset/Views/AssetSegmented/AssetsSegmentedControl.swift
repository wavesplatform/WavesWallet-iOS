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

final class AssetsSegmentedControl: UIView, NibOwnerLoadable {

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

    private var assets: [Asset] = []
    private(set) var currentPage: Int?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
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

//        let sections = [0, 1, 2, 3]
//        if newPage > currentPage {
//            tableView.reloadSections(sections, animationStyle: .left)
//        }
//        else {
//            tableView.reloadSections(sections, animationStyle: .right)
//        }
//
//        currentPage = newPage
//
//        labelTitle.text = headerItems[currentPage]
//        labelToken.text = headerItems[currentPage] + " token"
//
//        if currentPage == 2 {
//            viewSpam.isHidden = false
//            labelToken.isHidden = true
//        }
//        else {
//            viewSpam.isHidden = true
//            labelToken.isHidden = false
//        }
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

extension AssetsSegmentedControl: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        updateWithNewPage(indexPath.row)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

            updateWithNewPage(currentPageByContentOffset)
    }
}
