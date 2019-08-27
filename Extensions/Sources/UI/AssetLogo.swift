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

public enum AssetLogo {
    
    public struct Icon: Equatable, Codable {
        public let assetId: String
        public let name: String
        public let url: String?
        public let isSponsored: Bool
        public let hasScript: Bool
        
        public init(assetId: String,
                    name: String,
                    url: String?,
                    isSponsored: Bool,
                    hasScript: Bool) {
            
            self.assetId = assetId
            self.name = name
            self.url = url
            self.isSponsored = isSponsored
            self.hasScript = hasScript
        }
        
        var key: String {

            var keys: [String] = .init()
            
            keys.append(assetId)
            keys.append(name)
            keys.append("\(isSponsored)")
            keys.append("\(hasScript)")
            
            if let url = url {
                keys.append(url)
            }
            
            return keys.reduce(into: "", { $0 = $0 + "." + $1 })
        }
    }
    
    public struct Style: Hashable {
        public struct Border: Hashable {
            public let width: CGFloat
            public let color: UIColor
            
            public init(width: CGFloat,
                        color: UIColor) {
                self.width = width
                self.color = color
            }
        }
        
        public struct Specifications: Hashable {
            
            public let sponsoredImage: UIImage
            public let scriptImage: UIImage
            public let size: CGSize
            
            public init(sponsoredImage: UIImage,
                        scriptImage: UIImage,
                        size: CGSize) {
                self.sponsoredImage = sponsoredImage
                self.scriptImage = scriptImage
                self.size = size
            }
        }
        
        public let size: CGSize
        public let font: UIFont
        public let specs: Specifications
        
        public init(size: CGSize,
                    font: UIFont,
                    specs: Specifications) {
            self.size = size
            self.font = font
            self.specs = specs
        }
        
        var key: String {
            
            var keys: [String] = .init()
            
            keys.append("\(size.width)")
            keys.append("\(size.height)")
            keys.append("\(font.familyName)")
            keys.append("\(font.lineHeight)")
            keys.append("\(specs.size.width)")
            keys.append("\(specs.size.height)")
            
            
            return keys.reduce(into: "", { $0 = $0 + "." + $1 })
        }
    }
}

public extension AssetLogo {

    static func logo(icon: AssetLogo.Icon,
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
}

public extension AssetLogo {
    
    private static func cacheKeyForRemoteLogo(icon: AssetLogo.Icon,
                                              style: Style) -> String {
        return "com.wavesplatform.asset.logo.v3.\(icon.key).\(style.key)"
    }

    private static func cacheKeyForLocalLogo(icon: AssetLogo.Icon,
                                             style: Style) -> String {
        return "\(cacheKeyForRemoteLogo(icon: icon, style: style)).local"
    }


    private static func remoteLogo(icon: AssetLogo.Icon,
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
    }

    private static func prepareRemoteLogo(icon: AssetLogo.Icon,
                                          style: Style,
                                          image: UIImage) -> Observable<UIImage> {

        let image = rxCreateLogo(icon: icon,
                                 image: image,
                                 style: style)

        return image
            .flatMap({ (image) -> Observable<UIImage> in
                
                let key = cacheKeyForRemoteLogo(icon: icon, style: style)
                
                return saveImage(key: key, image: image ?? UIImage())
            })
    }

    private static func localLogo(icon: AssetLogo.Icon,
                                  style: Style) -> Observable<UIImage> {

        let localKey = cacheKeyForLocalLogo(icon: icon, style: style)
        return retrieveImage(key: localKey)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                } else {
                    let image = rxCreateLogo(icon: icon,
                                             image: nil,
                                             style: style)
                    
                    return image
                        .flatMap({ (image) -> Observable<UIImage> in
                            return saveImage(key: localKey, image: image ?? UIImage())
                        })
                }
            })
    }
    
    private static func rxCreateLogo(icon: AssetLogo.Icon,
                                     image: UIImage?,
                                     style: Style) -> Observable<UIImage?> {
        
        return Observable.create { (observer) -> Disposable in
            
            let logo = createLogo(icon: icon, image: image, style: style)
            observer.onNext(logo)
            observer.onCompleted()

            return Disposables.create {}
        }
        .observeOn(MainScheduler.asyncInstance)
    }

    private static func createLogo(icon: AssetLogo.Icon,
                                   image: UIImage?,
                                   style: Style) -> UIImage? {

        let size = style.size
        let font = style.font
        let name = icon.name

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
            let color = UIColor.colorAsset(assetId: icon.assetId)
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
        
        if icon.hasScript || icon.isSponsored {

            let rect = CGRect(x: size.width - style.specs.size.width,
                              y: size.height - style.specs.size.height,
                              width: style.specs.size.width,
                              height: style.specs.size.height)

            context.resetClip()
            context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
            context.clip()
            
            let color = UIColor.colorAsset(assetId: icon.assetId)
            context.setFillColor(color.cgColor)
            context.fill(rect)

            
            if icon.hasScript {
                style.specs.scriptImage.draw(in: rect)
            }
            
            if icon.isSponsored {
                style.specs.sponsoredImage.draw(in: rect)
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
