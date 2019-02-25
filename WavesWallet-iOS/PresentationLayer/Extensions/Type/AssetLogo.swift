//
//  AssetLogoStyle.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
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
    case wct = "wavescommunity"
    case bsv = "bsv"
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
        case .wct:
            return Images.logoWct48.image
        case .bsv:
            return Images.logoWct48.image
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
        let sponsoredSize: CGSize?
        let font: UIFont
        let border: Border?

        var key: String {
            var key = "\(size.width)_\(size.height)"
            key += "\(font.familyName)_\(font.lineHeight)"

            if let border = border {
                key += "\(border.width)_\(border.color.toHexString())"
            }
            
            if let sponsoredSize = sponsoredSize {
                key += "\(sponsoredSize.width)_\(sponsoredSize.height)"
            }
            return key
        }
    }

    private static func cacheKeyForRemoteLogo(icon: DomainLayer.DTO.Asset.Icon,
                                              style: Style) -> String {
        return "com.wavesplatform.asset.logo.v2.\(icon.name).\(style.key)"
    }

    private static func cacheKeyForLocalLogo(icon: DomainLayer.DTO.Asset.Icon,
                                             style: Style) -> String {
        return "\(cacheKeyForRemoteLogo(icon: icon, style: style)).local"
    }

    static func logo(icon: DomainLayer.DTO.Asset.Icon,
                     style: Style) -> Observable<UIImage> {

        let key = cacheKeyForRemoteLogo(icon: icon, style: style)

        return retrieveImage(key: key)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                } else {
                    if let url = icon.url {

                        return Observable.merge(localLogo(icon: icon,
                                                          style: style),
                                                remoteLogo(icon: icon,
                                                           style: style,
                                                           url: url))
                    } else {
                        return localLogo(icon: icon,
                                         style: style)
                    }
                }
            })
    }

    static func remoteLogo(icon: DomainLayer.DTO.Asset.Icon,
                           style: Style,
                           url: String) -> Observable<UIImage> {

        return retrieveImage(key: url)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return prepareRemoteLogo(icon: icon, style: style, image: image)
                } else {

                    return downloadImage(path: url)
                        .flatMap({ (image) -> Observable<UIImage> in

                            if let image = image {
                                return saveImage(key: url, image: image)
                                    .flatMap({ (image) -> Observable<UIImage> in
                                        return prepareRemoteLogo(icon: icon, style: style, image: image)
                                    })
                            } else {
                                return localLogo(icon: icon, style: style)
                            }
                        })
                }
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    static func prepareRemoteLogo(icon: DomainLayer.DTO.Asset.Icon,
                                  style: Style,
                                  image: UIImage) -> Observable<UIImage> {

        let image = createLogo(name: icon.name,
                               image: image,
                               style: style) ?? UIImage()

        let key = cacheKeyForRemoteLogo(icon: icon, style: style)

        return saveImage(key: key, image: image)
    }

    static func localLogo(icon: DomainLayer.DTO.Asset.Icon,
                          style: Style) -> Observable<UIImage> {

        let localKey = cacheKeyForLocalLogo(icon: icon, style: style)
        return retrieveImage(key: localKey)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                } else {
                    let logo = AssetLogo(rawValue: icon.name.lowercased())?.image48
                    let image = createLogo(name: icon.name,
                                           image: logo,
                                           style: style) ?? UIImage()

                    return saveImage(key: localKey, image: image)
                }
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    static func createLogo(name: String,
                           image: UIImage?,
                           style: Style) -> UIImage? {

        let size = style.size
        let font = style.font

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
        context.clip()

        if let image = image {

            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            image.draw(in: CGRect(x: 0,
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
        
        
        if let sponsoredSize = style.sponsoredSize {

            let rect = CGRect(x: size.width - sponsoredSize.width,
                              y: size.height - sponsoredSize.height,
                              width: sponsoredSize.width,
                              height: sponsoredSize.height)

            context.resetClip()
            context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
            context.clip()
            
            let color = UIColor.colorAsset(name: name)
            context.setFillColor(color.cgColor)
            context.fill(rect)

            let image = Images.sponsoritem18White.image
            image.draw(in: rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
