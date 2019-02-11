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

fileprivate enum Constants {
    static let spacing: CGFloat = 24
    static let scaleCell: CGFloat = 0.7
}

final class AssetsSegmentedControl: UIControl, NibOwnerLoadable {

    struct Model {
        struct Asset {
            enum Kind {
                case fiat
                case wavesToken
                case spam
                case gateway
            }
            let id: String
            let name: String
            let kind: Kind
            let icon: DomainLayer.DTO.Asset.Icon
        }

        let assets: [Asset]
        let currentAsset: Asset
    }

    @IBOutlet private var collectionView: InfiniteCollectionView!
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var detailLabel: UILabel!

    private var isTouchOnScrollView: Bool = false

    private var assets: [Model.Asset] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private(set) var currentPage: Int = 0

    var currentAsset: Model.Asset {
        return assets[currentPage]
    }

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

        collectionView.registerCell(type: AssetsSegmentedCell.self)
    }

    func setCurrentAsset(id: String, animated: Bool = true) {
        let element = assets.enumerated().first(where: { $0.element.id == id })
        guard let page = element?.offset else { return }
        setCurrentPage(page, animated: animated)
    }

    func setCurrentPage(_ page: Int, animated: Bool = true) {
        let newPage = collectionView.correctedIncorectIndex(page)
        collectionView.scrollToItem(at: IndexPath(item: newPage , section: 0), at: .centeredHorizontally, animated: animated)
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
            detailLabel.text = Localizable.Waves.General.Ticker.Title.fiatmoney
        case .gateway:
            detailLabel.text = Localizable.Waves.General.Ticker.Title.cryptocurrency
        case .spam:
            tickerView.update(with: .init(text: Localizable.Waves.General.Ticker.Title.spam,
                                          style: .normal))
        case .wavesToken:
            detailLabel.text = Localizable.Waves.General.Ticker.Title.wavestoken
        }
    }
}

extension AssetsSegmentedControl: InfiniteCollectionViewDataSource {

    func number(ofItems collectionView: UICollectionView) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        dequeueForItemAt dequeueIndexPath: IndexPath,
                        cellForItemAt usableIndexPath: IndexPath) -> UICollectionViewCell {

        let cell: AssetsSegmentedCell = collectionView.dequeueCellForIndexPath(indexPath: dequeueIndexPath)

        let asset = assets[usableIndexPath.row]

        let isHiddenArrow = asset.kind != .fiat || asset.kind != .gateway

        let model = AssetsSegmentedCell.Model(icon: asset.iconLogo,
                                              isHiddenArrow: isHiddenArrow)
        cell.update(with: model)

        return cell
    }
}

extension AssetsSegmentedControl: InfiniteCollectionViewDelegate {

    func infiniteCollectionView(_ collectionView: UICollectionView, didSelectItemAt usableIndexPath: IndexPath, dequeueForItemAt: IndexPath) {

        //TODO: need doing with animation and detect completed animation. 
        self.collectionView.scrollToItem(at: dequeueForItemAt, at: .centeredHorizontally, animated: false)
        self.sendActions(for: .valueChanged)
    }

    func scrollView(_ scrollView: UIScrollView, pageIndex: Int) {
        updateWithNewPage(pageIndex)
    }

    func scrollViewEndMoved(_ scrollView: UIScrollView, pageIndex: Int) {
        sendActions(for: .valueChanged)
    }
}

extension AssetsSegmentedControl: ViewConfiguration {
    func update(with model: Model) {
        self.assets = model.assets
        collectionView.reloadInfinity()
        setCurrentAsset(id: model.currentAsset.id, animated: false)
    }
}
