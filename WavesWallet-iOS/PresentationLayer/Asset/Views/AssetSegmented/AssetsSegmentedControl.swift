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
    static let spacing: Float = 24
}

final class AssetsSegmentedControl: UIView, NibOwnerLoadable {

    struct Model {
        enum Kind {
            case fiat
            case wavesToken
            case spam
            case gateway
        }
        let name: String
        let icon: UIImage
        let kind: Kind
    }

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var detailLabel: UILabel!
    @IBOutlet private var tickerViewBottomConstaint: NSLayoutConstraint!
    @IBOutlet private var detailLabelBottomConstaint: NSLayoutConstraint!

    private var isNeedUpdateConstraint: Bool = true
    private var isVisibleTicker: Bool = false
    private var models: [Model] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.models = [Model.init(name: "Waves", icon: UIImage(), kind: .fiat), Model.init(name: "Test2", icon: UIImage(), kind: .fiat)]

        detailLabel.isHidden = true
        tickerView.update(with: TickerView.Model(text: "Test", style: .normal))
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 24)
    }
}


//MARK: Private method

fileprivate extension AssetsSegmentedControl {

     var collectionPageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}

 //MARK: UICollectionViewDataSource

extension AssetsSegmentedControl: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetsSegmentedCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)

        let value = models[indexPath.row]

        

//        let iconName = DataManager.logoForCryptoCurrency(value)
//        if iconName.count == 0 {
//            cell.imageViewIcon.image = nil
//            cell.imageViewIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(value)
//            cell.labelTitle.text = String(value.uppercased().first!)
//        }
//        else {
//            cell.labelTitle.text = nil
//            cell.imageViewIcon.image = UIImage(named: iconName)
//        }
        return cell
    }
}
//
//extension AssetsSegmentedControl: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        if indexPath.row != currentPage {
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//
//        updateTableWithNewPage(indexPath.row)
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            let newPage = Int(floor((scrollView.contentOffset.x - collectionPageSize.width / 2) / collectionPageSize.width) + 1)
//            updateTableWithNewPage(newPage)
//        }
//        else {
//            updateTopBarOffset()
//        }
//    }
//}
