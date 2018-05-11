//
//  AssetLastTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AssetLastTransactionCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
    
    func setupCell(_ transactions: [String]) {
        
        if scrollView.subviews.count != transactions.count {
            
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            
            let offset: CGFloat = 10
            let startOffset: CGFloat = 10
            let viewWidth = Platform.ScreenWidth - 32
            
            for (index, value) in transactions.enumerated() {
                let view = AssetLastTransactionView.loadView() as! AssetLastTransactionView
                view.labelTitle.text = "Received " + value
                view.labelAssetName.text = value
                view.frame.size.width = viewWidth
                view.frame.origin.x = startOffset + CGFloat(index) * view.frame.size.width + offset * CGFloat(index)
                scrollView.addSubview(view)
            }
            scrollView.contentSize.width = viewWidth * CGFloat(transactions.count) + offset * CGFloat(transactions.count)
        }
     }
}
