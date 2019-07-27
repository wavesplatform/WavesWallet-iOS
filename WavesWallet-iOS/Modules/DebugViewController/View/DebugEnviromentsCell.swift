//
//  DebugEnviromentsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class DebugEnviromentsCell: UITableViewCell, Reusable {
    
    struct Model {
        let chainId: String
        let name: String
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var button: UIButton!
    
    var buttonDidTap: (() -> Void)?
    
    class func cellHeight() -> CGFloat {
        return Constants.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }
    
    @IBAction func handlerTapButton() {
        buttonDidTap?()
    }
    
    private func createLogo(chainId: String) -> UIImage? {
        
        let size = CGSize(width: 28, height: 28)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
        context.clip()
        
        
        context.setFillColor(UIColor.submit400.cgColor)
        context.fill(rect)
        
        if let first = chainId.first {
            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            let symbol = String(first).uppercased()
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attributedString = NSAttributedString(string: symbol,
                                                      attributes: [.foregroundColor: UIColor.white,
                                                                   .font: font,
                                                                   .paragraphStyle: style])
            let sizeStr = attributedString.size()
            
            attributedString.draw(with: CGRect(x: (size.width - sizeStr.width) * 0.5,
                                               y: (size.height - sizeStr.height) * 0.5,
                                               width: sizeStr.width,
                                               height: sizeStr.height),
                                  options: [.usesLineFragmentOrigin],
                                  context: nil)
        }
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: ViewConfiguration

extension DebugEnviromentsCell: ViewConfiguration {
    
    func update(with model: DebugEnviromentsCell.Model) {
        button.setImage(createLogo(chainId: model.chainId), for: .normal)
        button.setTitle(model.name, for: .normal)
    }
}


