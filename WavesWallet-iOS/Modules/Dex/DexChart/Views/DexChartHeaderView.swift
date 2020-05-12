//
//  DexChartHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools

protocol DexChartHeaderViewDelegate: AnyObject {
    func dexChartDidChangeTimeFrame(_ timeFrame: DomainLayer.DTO.Candle.TimeFrameType)
    func dexChartDidTapRefresh()
}

private enum Constants {
    static let animationKey = "rotation"
    static let animationDuration: TimeInterval = 1
}

final class DexChartHeaderView: UIView, NibOwnerLoadable {
    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var buttonRefresh: UIButton!

    private var timeFrame: DomainLayer.DTO.Candle.TimeFrameType!
    private var isRefreshing = false

    weak var delegate: DexChartHeaderViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    func setupTimeFrame(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) {
        self.timeFrame = timeFrame
        setuptTimeFrameTitle()
    }

    @IBAction private func refreshTapped(_: Any) {
        if isRefreshing {
            return
        }
        isRefreshing = true
        showAnimation()
        delegate?.dexChartDidTapRefresh()
    }

    func stopAnimation() {
        isRefreshing = false
        buttonRefresh.layer.removeAnimation(forKey: Constants.animationKey)
    }
}

// MARK: - SetupUI

private extension DexChartHeaderView {
    func setuptTimeFrameTitle() {
        labelTime.text = timeFrame.text
    }

    @IBAction func timeTapped(_: Any) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Localizable.Waves.Dexchart.Button.cancel, style: .cancel, handler: nil)
        controller.addAction(cancel)

        let types: [DomainLayer.DTO.Candle.TimeFrameType] = DomainLayer.DTO.Candle.TimeFrameType.all

        for type in types {
            let action = UIAlertAction(title: type.text, style: .default) { _ in

                if type == self.timeFrame {
                    return
                }
                self.timeFrame = type
                self.setuptTimeFrameTitle()
                self.delegate?.dexChartDidChangeTimeFrame(type)
            }

            controller.addAction(action)
        }
        firstAvailableViewController().present(controller, animated: true, completion: nil)
    }

    func showAnimation() {
        if buttonRefresh.layer.animation(forKey: Constants.animationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = Constants.animationDuration
            rotationAnimation.repeatCount = Float.infinity

            buttonRefresh.layer.add(rotationAnimation, forKey: Constants.animationKey)
        }
    }
}
