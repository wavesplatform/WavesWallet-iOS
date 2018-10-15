//
//  ChouseAccountCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import MGSwipeTableCell

final class ChouseAccountCell: MGSwipeTableCell, NibReusable {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
}
