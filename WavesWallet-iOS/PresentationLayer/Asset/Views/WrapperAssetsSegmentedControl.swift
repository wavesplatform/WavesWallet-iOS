//
//  WrapperAssetsSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 10/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate enum Constants {
    static let maxCount = 3
}

final class WrapperAssetsSegmentedControl: UIView {
    @IBOutlet private(set) var assetsSegmentedControl: AssetsSegmentedControl!
    private var leftGradient: GradientView = GradientView()
    private var rightGradient: GradientView = GradientView()

    override func awakeFromNib() {
        super.awakeFromNib()
        leftGradient.startColor = .basic50
        leftGradient.endColor = UIColor.basic50.withAlphaComponent(0.0)
        leftGradient.direction = .custom(GradientView.Settings.init(startPoint: CGPoint(x: 0.0, y: 0),
                                                                    endPoint: CGPoint(x: 1, y: 0),
                                                                    locations: [0.7, 1]))

        rightGradient.startColor = UIColor.basic50.withAlphaComponent(0.0)
        rightGradient.endColor = .basic50
        rightGradient.direction = .custom(GradientView.Settings.init(startPoint: CGPoint(x: 0.0, y: 0),
                                                                    endPoint: CGPoint(x: 1.0, y: 0),
                                                                    locations: [0, 0.3]))

        backgroundColor = .basic50
        assetsSegmentedControl.backgroundColor = .basic50
        addSubview(leftGradient)
        addSubview(rightGradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let witdthCells = self.witdthCells()

        leftGradient.frame = CGRect(x: 0,
                                    y: 0,
                                    width: (frame.width - witdthCells) * 0.5,
                                    height: AssetsSegmentedCell.Constants.sizeLogo.height)
        rightGradient.frame = CGRect(x: frame.width - (frame.width - witdthCells) * 0.5,
                                     y: 0,
                                     width: (frame.width - witdthCells) * 0.5,
                                     height: AssetsSegmentedCell.Constants.sizeLogo.height)
    }

    func witdthCells() -> CGFloat {
        return assetsSegmentedControl.witdthCells(by: Constants.maxCount)
    }

    func setCurrentAsset(id: String, animated: Bool = true) {
        assetsSegmentedControl.setCurrentAsset(id: id, animated: animated)
    }

    func currentAssetId() -> Signal<String> {

        return self
            .assetsSegmentedControl
            .rx
            .controlEvent(.valueChanged)
            .flatMap({ [weak self] _ -> Observable<String> in
                guard let strongSelf = self else { return Observable.empty() }
                return Observable.just(strongSelf.assetsSegmentedControl.currentAsset.id)
            })
            .asSignal(onErrorSignalWith: Signal.empty())

    }
}

// MARK: ViewConfiguration

extension WrapperAssetsSegmentedControl: ViewConfiguration {

    func update(with model: AssetsSegmentedControl.Model) {
        assetsSegmentedControl.update(with: model)
        setNeedsLayout()
    }
}
