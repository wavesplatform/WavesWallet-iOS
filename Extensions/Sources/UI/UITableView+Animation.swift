//
//  UITableView+Animation.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public extension UITableView {

    func reloadDataWithAnimationTheCrossDissolve(completion: (() -> Void)? = nil) {
        UIView.transition(with: self,
                          duration: 0.24,
                          options: [.transitionCrossDissolve,
                                    .curveEaseInOut],
                          animations: {
                            self.reloadData()
        }, completion: { _ in completion?() })
    }
}
