//
//  PageControl.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let deffaultNumberOfPages: Int = 3
    static let padding: CGFloat = 8
    static let durationAnimation: TimeInterval = 0.3
}

public class PageControl: UIStackView {

    @IBInspectable var currentPageImage: UIImage = UIImage(named: "slide_point_line")!
    @IBInspectable var pageImage: UIImage = UIImage(named: "slide_point_dot")!
    
    var numberOfPages = Constants.deffaultNumberOfPages {
        didSet {
            layoutIndicators()
        }
    }

    var currentPage = 0 {
        didSet {
            setCurrentPageIndicator()
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        spacing = Constants.padding
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .center

        layoutIndicators()
    }

    private func layoutIndicators() {

        for index in 0..<numberOfPages {

            let imageView: UIImageView

            if index < arrangedSubviews.count {
                imageView = arrangedSubviews[index] as! UIImageView // reuse subview if possible
            } else {
                imageView = UIImageView()
                addArrangedSubview(imageView)
            }

            if index == currentPage {
                imageView.image = currentPageImage
            } else {
                imageView.image = pageImage
            }
        }
        
        let subviewCount = arrangedSubviews.count
        if numberOfPages < subviewCount {
            for _ in numberOfPages..<subviewCount {
                arrangedSubviews.last?.removeFromSuperview()
            }
        }
    }

    private func setCurrentPageIndicator() {

        for index in 0..<arrangedSubviews.count {

            let imageView = arrangedSubviews[index] as! UIImageView

            
            UIView.transition(with: imageView,
                              duration: Constants.durationAnimation,
                              options: .transitionCrossDissolve,
                              animations: {
                                if index == self.currentPage {
                                    imageView.image = self.currentPageImage
                                } else {
                                    imageView.image = self.pageImage
                                }
            })
              
        }
    }
}
