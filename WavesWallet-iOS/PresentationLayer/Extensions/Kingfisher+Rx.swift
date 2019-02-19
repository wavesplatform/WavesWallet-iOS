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

    return Observable.create({ (observer) -> Disposable in

        let cache = ImageCache.default
        cache.store(image, forKey: key)
        observer.onNext(image)
        observer.onCompleted()

        return Disposables.create {}
    })
}

func retrieveImage(key: String) -> Observable<UIImage?> {

    return Observable.create({ (observer) -> Disposable in

        let cache = ImageCache.default

        cache.retrieveImage(forKey: key,
                            options: nil,
                            completionHandler: { image, _ in
                                observer.onNext(image)
                                observer.onCompleted()
        })

        return Disposables.create {}
    })
}

func downloadImage(path: String) -> Observable<UIImage?> {

    return Observable.create({ (observer) -> Disposable in

        let url = URL(string: path)!
        let downloader = ImageDownloader.default
        let workItem = downloader.downloadImage(with: url,
                                                retrieveImageTask: nil,
                                                options: nil,
                                                progressBlock: nil) { (image, error, url, data) in

                                                    if let data = data, let pic = UIImage(data: data) {
                                                        observer.onNext(pic)
                                                        observer.onCompleted()
                                                    } else {
                                                        observer.onNext(nil)
                                                        observer.onCompleted()
                                                    }
        }

        return Disposables.create {
            workItem?.cancel()
        }
    })
}
