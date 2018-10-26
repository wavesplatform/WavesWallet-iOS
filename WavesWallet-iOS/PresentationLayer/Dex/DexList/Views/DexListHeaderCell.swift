//
//  DexListHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/31/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import SwiftDate


final class DexListHeaderCell: UITableViewCell, Reusable {

    @IBOutlet weak var labelTitle: UILabel!
    
    private let formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class func cellHeight() -> CGFloat {
        return 25
    }
   
}

extension DexListHeaderCell {
    
    func update(with date: Date) {
        
        if date.isToday {
            formatter.dateFormat = "HH:mm"
            labelTitle.text = Localizable.Waves.Dexlist.Label.lastUpdate + ": " +
                Localizable.Waves.Dexlist.Label.today + ", " + formatter.string(from: date)
        }
        else if date.isYesterday {
            formatter.dateFormat = "HH:mm"
            labelTitle.text = Localizable.Waves.Dexlist.Label.lastUpdate + ": " +
                Localizable.Waves.Dexlist.Label.yesterday + ", " + formatter.string(from: date)
        }
        else {
            formatter.timeStyle = .short
            formatter.dateStyle = .long
            labelTitle.text = formatter.string(from: date)
        }
    }
}
