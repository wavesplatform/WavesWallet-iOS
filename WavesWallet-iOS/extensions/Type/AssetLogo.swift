//
//  AssetLogoStyle.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Kingfisher

enum AssetLogo: String {
    case waves = "waves"
    case usd = "usd"
    case monero = "xmr"
    case litecoin = "ltc"
    case lira = "try"
    case eur = "eur"
    case eth = "eth"
    case dash = "dash"
    case bitcoinCash = "bch"
    case bitcoin = "btc"
    case zcash = "zec"
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
        case .zcash:
            return Images.logoZec48.image
        }
    }
}

//UIFont.systemFont(ofSize: 15)
extension AssetLogo {

    struct Style: Hashable {
        struct Border: Hashable {
            let width: CGFloat
            let color: UIColor
        }

        let size: CGSize
        let font: UIFont
        let border: Border?

        var key: String {
            var key = "\(size.width)_\(size.height)"
            key += "\(font.familyName)_\(font.lineHeight)"

            if let border = border {
                key += "\(border.width)_\(border.color.toHexString())"
            }
            return key
        }
    }

    static func logoFromCache(name: String,
                              style: Style,
                              completionHandler: @escaping ((UIImage) -> Void)) -> RetrieveImageDiskTask?
    {
        let cache = ImageCache.default
        let key = "com.wavesplatform.asset.logo.\(name).\(style.key)"

        return cache.retrieveImage(forKey: key,
                                   options: nil,
                                   completionHandler: { image, _ in
                                    if let image = image {
                                        completionHandler(image)
                                    } else {
                                        if let image = createLogo(name: name, style: style) {
                                            cache.store(image, forKey: key)
                                            completionHandler(image)
                                        }
                                    }
        })
    }

    static func createLogo(name: String,
                           style: Style) -> UIImage? {

        let size = style.size
        let font = style.font

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
        context.clip()

        if let logo = AssetLogo(rawValue: name.lowercased()) {

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

        if let border = style.border {
            context.addArc(center: CGPoint(x: size.width * 0.5, y: size.height * 0.5), radius: size.height * 0.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
            context.setLineWidth(border.width)
            context.setStrokeColor(border.color.cgColor)
            context.strokePath()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}
