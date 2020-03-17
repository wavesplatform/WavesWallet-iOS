//
//  BlueButton.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class BlueButton: UIView, NibOwnerLoadable {
    
    struct Model: Hashable {
        enum Status: Hashable {
            case disabled
            case active
            case loading
        }
        
        let title: String
        let status: Status
    }
    
    @IBOutlet private var button: UIButton!
    @IBOutlet private var indicatorView: UIActivityIndicatorView!
            
    var didTouchButton: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.setBackgroundImage(UIColor.submit400.image, for: .normal)
        button.setBackgroundImage(UIColor.submit200.image, for: .disabled)
    }
    
    @IBAction private func handlerTapButton() {
        didTouchButton?()
    }
}

// MARK: ViewConfiguration

extension BlueButton: ViewConfiguration {
 
    func update(with model: Model) {
            
        button.setTitle(model.title, for: .normal)
                
        switch model.status {
        case .disabled:
            button.isEnabled = false
            indicatorView.stopAnimating()
            
        case .active:
            button.isEnabled = true
            indicatorView.stopAnimating()
            
        case .loading:
            button.isEnabled = false
            indicatorView.startAnimating()
        }

    }
}

