//
//  Kingfisher+Rx.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Kingfisher
import RxSwift

public func retrieveOrDonwloadImage(key: String, url: String) -> Observable<UIImage?> {

    return retrieveImage(key: key)
        .flatMap({ (image) -> Observable<UIImage?> in
            if let image = image {
                return Observable.just(image)
            } else {
                return downloadImage(path: url)
                    .flatMap({ (image) -> Observable<UIImage?> in
                        if let image = image {
                            return saveImage(key: key, image: image).map { $0 }
                        } else {
                            return Observable.just(nil)
                        }
                    })
            }
        })
}

public func saveImage(key: String, image: UIImage) -> Observable<UIImage> {
   return ImageCache.default.rx.saveImage(key: key, image: image)
}

public func retrieveImage(key: String) -> Observable<UIImage?> {
    return ImageCache.default.rx.retrieveImage(key: key)
}

public func clearImageCache() {
    ImageCache.default.clearDiskCache()
    ImageCache.default.clearMemoryCache()
    ImageCache.default.cleanExpiredDiskCache()
    ImageCache.default.cleanExpiredMemoryCache()
}

public func downloadImage(path: String) -> Observable<UIImage?> {
    return ImageDownloader.default.rx.downloadImage(path: path)
}

public extension Reactive where Base == ImageDownloader {
    
    public func downloadImage(path: String) -> Observable<UIImage?> {
        
        return Observable.create({ [base] (observer) -> Disposable in
            
            guard let url = URL(string: path) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let downloader = base
            
            var isFinish = false
            let workItem = downloader.downloadImage(with: url,
                                                    options: nil,
                                                    progressBlock: nil,
                                                    completionHandler:
                { (result) in
                    isFinish = true
                    
                    if let pic = try? result.get().image {
                        observer.onNext(pic)
                        observer.onCompleted()
                    } else {
                        observer.onNext(nil)
                        observer.onCompleted()
                    }
                })
            
            
            return Disposables.create {
                if isFinish == false {
                    workItem?.cancel()
                }
            }
        })
    }
}

extension ImageDownloader: ReactiveCompatible {
    public var rx: Reactive<ImageDownloader> {
        get { return Reactive(self) }
        set { }
    }
}

public extension Reactive where Base == ImageCache {
    
    public func saveImage(key: String, image: UIImage) -> Observable<UIImage> {
        
        return Observable.create({ [base] (observer) -> Disposable in
            
            let cache = base
            cache.store(image, forKey: key)
            observer.onNext(image)
            observer.onCompleted()
            
            return Disposables.create {}
        })
    }
    
    public func retrieveImage(key: String) -> Observable<UIImage?> {
        
      return Observable.create({ [base] (observer) -> Disposable in

        let cache = base        
        if let memoryImage = cache.retrieveImageInMemoryCache(forKey: key) {
            observer.onNext(memoryImage)
        }
        else {
            let diskImage = cache.retrieveImageInDiskCache(forKey: key)
            if let image = diskImage {
                cache.store(image, forKey: key, toDisk: false)
            }
            observer.onNext(diskImage)
            
        }
        observer.onCompleted()
        
        return Disposables.create {}
    })      
  }
}

extension ImageCache: ReactiveCompatible {
    public var rx: Reactive<ImageCache> {
        get { return Reactive(self) }
        set { }
    }
}
