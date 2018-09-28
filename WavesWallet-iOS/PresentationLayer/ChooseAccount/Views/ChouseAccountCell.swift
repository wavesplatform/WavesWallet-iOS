//
//  ChouseAccountCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class ChouseAccountCell: MGSwipeTableCell, NibReusable {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAddress: UILabel!


    override func awakeFromNib() {
        let view = UIView(frame: CGRect(x: 16, y: 4, width: Platform.ScreenWidth - 32, height: frame.size.height - 8))
        view.layer.cornerRadius = 3
        view.backgroundColor = .overlayDark
        insertSubview(view, at: 0)
    }
}
