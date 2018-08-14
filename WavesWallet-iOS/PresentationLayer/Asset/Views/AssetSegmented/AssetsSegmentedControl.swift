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
import InfiniteCollectionView

private enum Constants {
    static let spacing: CGFloat = 24
    static let scaleCell: CGFloat = 0.7
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

    @IBOutlet private var collectionView: InfiniteCollectionView!
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
            self.collectionView?.backgroundColor = backgroundColor
            self.collectionView?.backgroundView = {
                let view = UIView()
                view.backgroundColor = backgroundColor
                return view
            }()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.infiniteDataSource = self
        collectionView.delegate = collectionView
        collectionView.dataSource = collectionView
        collectionView.infiniteDelegate = self

        tickerView.isHidden = true
        detailLabel.isHidden = true

        let layout = collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: Constants.spacing)
        layout.sideItemScale = Constants.scaleCell
    }

    func setCurrentPage(_ page: Int, animated: Bool = true) {
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0),
                                    at: .centeredHorizontally,
                                    animated: animated)
        updateWithNewPage(page)
    }

    func witdthCells(by count: Int) -> CGFloat {
        switch count {
        case 0:
            return 0
        case 1:
            return AssetsSegmentedCell.Constants.sizeLogo.width
        default:
            let smallCellsCount: CGFloat = CGFloat(count) - 1
            return  AssetsSegmentedCell.Constants.sizeLogo.width
                + (AssetsSegmentedCell.Constants.sizeLogo.width * Constants.scaleCell) * smallCellsCount
                + Constants.spacing * smallCellsCount
        }
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

        titleLabel.text = asset.name
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

extension AssetsSegmentedControl: InfiniteCollectionViewDataSource {

    func number(ofItems collectionView: UICollectionView) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        dequeueForItemAt dequeueIndexPath: IndexPath,
                        cellForItemAt usableIndexPath: IndexPath) -> UICollectionViewCell {

        let cell: AssetsSegmentedCell = collectionView.dequeueAndRegisterCell(indexPath: dequeueIndexPath)

        let asset = assets[usableIndexPath.row]

        let isHiddenArrow = asset.kind != .fiat || asset.kind != .gateway

        let model = AssetsSegmentedCell.Model(icon: asset.name,
                                              isHiddenArrow: isHiddenArrow)
        cell.update(with: model)
        return cell
    }
}

extension AssetsSegmentedControl: InfiniteCollectionViewDelegate {

    func infiniteCollectionView(_ collectionView: UICollectionView, didSelectItemAt usableIndexPath: IndexPath, dequeueForItemAt: IndexPath) {
        collectionView.scrollToItem(at: IndexPath(item: dequeueForItemAt.row, section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
    }

    func scrollView(_ scrollView: UIScrollView, pageIndex: Int) {
        updateWithNewPage(pageIndex)
    }
}

extension AssetsSegmentedControl: ViewConfiguration {
    func update(with model: [AssetsSegmentedControl.Asset]) {
        self.assets = model
        collectionView.reloadData()        
    }
}
