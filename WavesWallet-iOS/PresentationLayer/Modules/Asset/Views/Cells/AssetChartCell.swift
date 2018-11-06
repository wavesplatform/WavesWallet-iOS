
//
//  AssetChartCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Charts

class AssetChartCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewRight: UIView!
    @IBOutlet weak var imageChartEmpty: UIImageView!
    @IBOutlet weak var labelNoChartData: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        viewContainer.addTableCellShadowStyle()
        
        chartView.chartDescription?.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.xAxis.enabled = false
        chartView.minOffset = 0
        chartView.noDataText = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellHeight() -> CGFloat {
        return 220
    }

    func setupCell(isNoDataChart: Bool) {
        
        if isNoDataChart {
            chartView.isHidden = true
            viewLeft.isHidden = true
            viewRight.isHidden = true
            
            imageChartEmpty.isHidden = false
            labelNoChartData.isHidden = false
        }
        else {
            chartView.isHidden = false
            viewLeft.isHidden = false
            viewRight.isHidden = false
            
            imageChartEmpty.isHidden = true
            labelNoChartData.isHidden = true
        }
        
        
        if chartView.data != nil {
            return
        }
        
        let values = (0..<50).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(10) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set = LineChartDataSet(values: values, label: "DataSet")
        set.drawValuesEnabled = false
        set.drawIconsEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawCirclesEnabled = false
        set.setColor(.submit300)
        set.lineWidth = 2
        set.highlightEnabled = false
        let data = LineChartData(dataSet: set)
        
        chartView.data = data
    }
}
