//
//  DexChartHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol DexChartHeaderViewDelegate: AnyObject {

    func dexChartDidChangeTimeFrame(_ timeFrame: DexChart.DTO.TimeFrameType)
}

final class DexChartHeaderView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelFull: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
   
    private var timeFrame: DexChart.DTO.TimeFrameType!
    
    weak var delegate: DexChartHeaderViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setupTimeFrame(timeFrame:  DexChart.DTO.TimeFrameType) {
        self.timeFrame = timeFrame
        setuptTimeFrameTitle()
    }
}

//MARK: - SetupUI

private extension DexChartHeaderView {
    
    func setuptTimeFrameTitle() {
        labelTime.text = timeFrame.text
    }
    
    @IBAction func timeTapped(_ sender: Any) {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: Localizable.DexChart.Button.cancel, style: .cancel, handler: nil)
        controller.addAction(cancel)

        let types: [DexChart.DTO.TimeFrameType] = [.m5, .m15, .m30, .h1, .h4, .h24]
        
        for type in types {
            let action = UIAlertAction(title: type.text, style: .default) { (action) in
                
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
}
