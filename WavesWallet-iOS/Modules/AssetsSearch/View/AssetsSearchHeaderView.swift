//
//  AssetsSearchHeaderView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private struct Constants {
    static let cornerRadius: CGFloat = 12
    static let startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5)
    static let endPoint: CGPoint = CGPoint(x: 0.0, y: 1)
}

final class AssetsSearchHeaderView: UIView, NibLoadable {
    
    struct Model {
        let title: String
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var topBackgroundView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    
    // TODO: Change icon to black
    @IBOutlet private(set) weak var searchBarView: SearchBarView!
    
    var isHiddenSepatator: Bool = true {
        didSet {
            self.separatorView.isHidden = self.isHiddenSepatator
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.isHidden = true        
        backgroundColor = .clear
        layer.cornerRadius = Constants.cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        topBackgroundView.layer.cornerRadius = Constants.cornerRadius
        topBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        if let searchBarView = searchBarView {
            let searchBarFrame = searchBarView.convert(searchBarView.frame, to: self)
            
            if searchBarFrame.contains(point) {
                return self
            }
        }
        
        return super.hitTest(point, with: event)
    }
}

extension AssetsSearchHeaderView: ViewConfiguration {
    
    func update(with model: AssetsSearchHeaderView.Model) {
        self.labelTitle.text = model.title
    }
}


