//
//  NavigationAccessoryView.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 21/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

/// Class for the navigation accessory view used in FormViewController
open class NavigationAccessoryView: UIToolbar {
    open var previousButton: UIBarButtonItem!
    open var nextButton: UIBarButtonItem!
    open var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private var fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    private var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44.0))
        autoresizingMask = .flexibleWidth
        fixedSpace.width = 22.0
        initializeChevrons()
        setItems([previousButton, fixedSpace, nextButton, flexibleSpace, doneButton], animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initializeChevrons() {
        var imageLeftChevron = UIImage(named: "back-chevron")
        var imageRightChevron = UIImage(named: "forward-chevron")
        // RTL language support
        if #available(iOS 9.0, *) {
            imageLeftChevron = imageLeftChevron?.imageFlippedForRightToLeftLayoutDirection()
            imageRightChevron = imageRightChevron?.imageFlippedForRightToLeftLayoutDirection()
        }
        
        previousButton = UIBarButtonItem(image: imageLeftChevron, style: .plain, target: nil, action: nil)
        nextButton = UIBarButtonItem(image: imageRightChevron, style: .plain, target: nil, action: nil)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
