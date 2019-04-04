//
//  Kingfisher+Rx.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Kingfisher
import RxSwift

func retrieveOrDonwloadImage(key: String, url: String) -> Observable<UIImage?> {

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

func saveImage(key: String, image: UIImage) -> Observable<UIImage> {
   return ImageCache.default.rx.saveImage(key: key, image: image)
}

func retrieveImage(key: String) -> Observable<UIImage?> {
    return ImageCache.default.rx.retrieveImage(key: key)
}

func clearImageCache() {
    ImageCache.default.clearDiskCache()
    ImageCache.default.clearMemoryCache()
    ImageCache.default.cleanExpiredDiskCache()
    ImageCache.default.cleanExpiredMemoryCache()
}

func downloadImage(path: String) -> Observable<UIImage?> {
    return ImageDownloader.default.rx.downloadImage(path: path)
}

extension Reactive where Base == ImageDownloader {
    
    func downloadImage(path: String) -> Observable<UIImage?> {
        
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
                    if let pic = result.value?.image {
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

extension Reactive where Base == ImageCache {
    
    func saveImage(key: String, image: UIImage) -> Observable<UIImage> {
        
        return Observable.create({ [base] (observer) -> Disposable in
            
            let cache = base
            cache.store(image, forKey: key)
            observer.onNext(image)
            observer.onCompleted()
            
            return Disposables.create {}
        })
    }
    
    func retrieveImage(key: String) -> Observable<UIImage?> {
        
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
