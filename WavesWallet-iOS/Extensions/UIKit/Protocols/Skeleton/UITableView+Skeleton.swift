//
//  UITableView+Skeleton.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 27.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UITableView {

    func startSkeleton() {
        visibleCells.forEach { cell in
            if let skeletonView = cell as? SkeletonAnimatable {
                skeletonView.startAnimation(to: .right)
            }
        }
    }
}
