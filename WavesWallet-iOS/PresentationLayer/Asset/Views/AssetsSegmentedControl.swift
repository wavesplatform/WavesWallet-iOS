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

final class AssetsSegmentedControl: UIView {

    @IBOutlet var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

//        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
//        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 24)
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

// MARK: UICollectionViewDataSource

//extension AssetsSegmentedControl: UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return headerItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionHeaderCell", for: indexPath) as! AssetCollectionHeaderCell
//
//        let value = headerItems[indexPath.row]
//
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
//        return cell
//    }
//}
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
