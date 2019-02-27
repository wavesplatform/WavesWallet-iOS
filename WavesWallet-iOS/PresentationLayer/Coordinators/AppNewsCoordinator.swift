//
//  AppNewsCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

private struct ApplicationNewsSettings: TSUD, Codable, Mutating {

    var showIdSet: Set<String> = Set<String>()

    private enum Constants {
        static let key: String = "com.waves.application.news.settings"
    }

    init(showIdSet: Set<String>) {
        self.showIdSet = showIdSet
    }

    init() {
        showIdSet = .init()
    }

    static var defaultValue: ApplicationNewsSettings {
        return ApplicationNewsSettings(showIdSet: .init())
    }

    static var stringKey: String {
        return Constants.key
    }
}

final class AppNewsCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let notificationNewsRepository: NotificationNewsRepositoryProtocol = FactoryRepositories.instance.notificationNewsRepository

    private let disposeBag: DisposeBag = DisposeBag()

    init() {}

    func start()  {

        notificationNewsRepository
            .notificationNews()            
            .asDriver(onErrorJustReturn: [])
            .asObservable()
            .subscribe(onNext: { [weak self] (news) in
                self?.showNews(news)
            })
            .disposed(by: disposeBag)
    }

    private func showNews(_ news: [DomainLayer.DTO.NotificationNews]) {
        let settings = ApplicationNewsSettings.get()

        let now = Date()

        let filerNews = news.filter { (news) -> Bool in
            return settings.showIdSet.contains(news.id) == false && now.isBetween(news.startDate, and: news.endDate)
        }

        guard let first = filerNews.first else {
            closeCoordinator()
            return
        }

        let code = Language.currentLanguage.code
        let defaultLanguageCode = Language.defaultLanguage.code

        var title = first.title[code]

        if title == nil {
            title = first.title[defaultLanguageCode]
        }

        var subTitle = first.subTitle[code]

        if subTitle == nil {
            subTitle = first.subTitle[defaultLanguageCode]
        }

        let titleValue = title ?? ""
        let subTitleValue = subTitle ?? ""

        retrieveOrDonwloadImage(key: first.logoUrl, url: first.logoUrl)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (image) in
                if let image = image {
                     let news = AppNewsView.show(model: .init(title: titleValue,
                                                              subtitle: subTitleValue,
                                                              image: image))
                    news.tapDismiss = { [weak self] in
                        self?.closeCoordinator()
                    }

                    var showIdSet = settings.showIdSet
                    showIdSet.insert(first.id)

                    let settings = ApplicationNewsSettings(showIdSet: showIdSet)
                    ApplicationNewsSettings.set(settings)

                } else {
                    self?.closeCoordinator()
                }
            })
            .disposed(by: disposeBag)
    }

    private func closeCoordinator() {
        removeFromParentCoordinator()
    }
}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
