//
//  TopContainer2.swift
//  testApp
//
//  Created by Pavel Gubin on 5/24/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

class TopContainer2: ContainerView {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.containerViewDidRemoveView(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.cornerRadius = 4
        
        labelTitle.text = "gskl jlfkalk fdhsfjakl jdaksl jddaklfjals;k ;lkdflhl dhskf skdjalfjlsd aljdfhjalsjd klasfjhaslkfjklafjk ladjkf dhjsk387413 bkjskaf384783h dfkshj38487347bn4389471894h fdjahfkj 3417487"
        
        let containerTopOffset: CGFloat = 20
        let labelTopOffset: CGFloat = 20
        
        let containerPadding: CGFloat = 20
        let labelPadding: CGFloat = 20
        let height = labelTitle.text!.maxHeight(font: labelTitle.font,
                                                forWidth: UIScreen.main.bounds.size.width - containerPadding * 2 - labelPadding * 2)
        
        frame.size.height = height + labelTopOffset * 2 + containerTopOffset * 2
    }
    
    deinit {
        print(classForCoder, #function)
    }

}
