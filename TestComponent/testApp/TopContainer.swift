//
//  TopContainer.swift
//  testApp
//
//  Created by Pavel Gubin on 5/15/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

class TopContainer: ContainerView {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.layer.cornerRadius = 4
        
        labelTitle.text = "dsakdk ajfkdashfj shkf adhsjk fdhjkf dkshfjkdshfjk dhfjk dshfjk dhf jdhskjf dkfdhsjfhdskjf dksfsjkfhdksjfh djkfjksx1fhdksjfh djkfjksx1fhdksjfh djkfjksx1fhdksjfh djkfjksx1fhdksjfh djkfjksx1fhdksjfh djkfjksx1fhdksjfh djkfjksx1 dalskdlaskdxzxx 1234"
    
        let containerTopOffset: CGFloat = 20
        let labelTopOffset: CGFloat = 20
        
        let containerPadding: CGFloat = 20
        let labelPadding: CGFloat = 20
        let height = labelTitle.text!.maxHeight(font: labelTitle.font,
                                                forWidth: UIScreen.main.bounds.size.width - containerPadding * 2 - labelPadding * 2)
        
        frame.size.height = height + labelTopOffset * 2 + containerTopOffset * 2
    }
    
    @IBAction func crossTapped(_ sender: Any) {
        delegate?.containerViewDelegateDidRemoveView(self)
    }
    
    deinit {
        print(classForCoder, #function)
    }
}
