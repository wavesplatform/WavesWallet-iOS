//
//  UIImage+Asset.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher
enum AssetLogo: String {
    case waves
    case usd
    case monero
    case litecoin
    case lira = "try"
    case eur
    case eth
    case dash
    case bitcoinCash = "bitcoin cash"
    case bitcoin = "btc"
}

extension AssetLogo {
    var image48: UIImage {
        switch self {
        case .waves:
            return Images.logoWaves48.image
        case .usd:
            return Images.logoUsd48.image
        case .monero:
            return Images.logoMonero48.image
        case .litecoin:
            return Images.logoLtc48.image
        case .lira:
            return Images.logoLira48.image
        case .eur:
            return Images.logoEuro48.image
        case .eth:
            return Images.logoEthereum48.image
        case .dash:
            return Images.logoDash48.image
        case .bitcoin:
            return Images.logoBitcoin48.image
        case .bitcoinCash:
            return Images.logoBitcoincash48.image
        }
    }
}

extension UIImage {

    static func assetLogoFromCache(name: String,
                                   size: CGSize,
                                   font: UIFont = UIFont.systemFont(ofSize: 15),
                                   completionHandler: @escaping ((UIImage) -> Void)) -> RetrieveImageDiskTask? {
        let cache = ImageCache.default
        let key = "com.wavesplatform.asset.logo.\(name).\(size).\(font.fontName).\(font.lineHeight)"

        return cache.retrieveImage(forKey: key,
                                   options: nil,
                                   completionHandler: { image, _ in
            if let image = image {
                completionHandler(image)
            } else {
                if let image = createdAssetLogo(name: name,
                                                size: size,
                                                font: font) {
                    cache.store(image, forKey: key)
                    completionHandler(image)
                }
            }
        })
    }

    static func createdAssetLogo(name: String,
                                 size: CGSize,
                                 font: UIFont = UIFont.systemFont(ofSize: 15)) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
        context.clip()

        if let logo = AssetLogo(rawValue: name.lowercased()) {
            //TODO: Need image without corner radius
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            logo.image48.draw(in: CGRect(x: 0,
                                       y: 0,
                                       width: size.width,
                                       height: size.height),
                            blendMode: .normal,
                            alpha: 1)
        } else {
            let color = UIColor.colorAsset(name: name)
            context.setFillColor(color.cgColor)
            context.fill(rect)
            if let first = name.first {
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
        }



        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}
