//
//  TodayViewController.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import NotificationCenter
import RxSwift
import RxCocoa
import RxFeedback
import WavesSDK

//1. Показ ошибки, в таргет нужно добавлять файлы локализации
//2. Кешировать респонс в БД и сначала отображать данные из кеша а потом из сети
//3. Сделать чтобы пары брались из БД
//4. Кнопку настройки сделать
//5. Загрузку лого
//6. Обновление данных по интервалу

private enum Constants {
    static let bottomViewHeight: CGFloat = 34
    static let buttonUpdateOffset: CGFloat = 40
    
    static let animationKey = "rotation"
    static let animationDuration: TimeInterval = 1
}

final class MarketPulseWidgetViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonCurrency: UIButton!
    @IBOutlet private weak var buttonUpdate: UIButton!
    @IBOutlet private weak var buttonSettings: UIButton!
    @IBOutlet private weak var buttonUpdateWidth: NSLayoutConstraint!
    @IBOutlet private weak var viewDarkMode: UIView!
    
    private var currency = MarketPulse.Currency.usd
    private var isDarkMode: Bool = false
    private var isUpdating = true

    private var presenter: MarketPulseWidgetPresenterProtocol!
    private let sendEvent: PublishRelay<MarketPulse.Event> = PublishRelay<MarketPulse.Event>()
    private var items: [MarketPulse.ViewModel.Row] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        initPresenter()
        initSDK()
        setupFeedBack()
        setupDarkMode()
        setupCurrencyTitle()
        setupButtonUpdateSize()
        showUpdateAnimation()
        
//        let fileURL = FileManager.default
//            .containerURL(forSecurityApplicationGroupIdentifier: "group.io.realm.app_group")!
//            .appendingPathComponent("default.realm")
//        let config = Realm.Configuration(fileURL: fileURL)
//        let realm = try Realm(configuration: config)
        
    }
   
    @IBAction private func settingsTapped(_ sender: Any) {
        
    }
    
    @IBAction private func updateTapped(_ sender: Any) {
        sendEvent.accept(.refresh)
        showUpdateAnimation()
    }
    
    @IBAction private func changeCurrency(_ sender: Any) {
        if currency == .usd {
            currency = .eur
        }
        else {
            currency = .usd
        }
        setupCurrencyTitle()
        sendEvent.accept(.changeCurrency(currency))
    }
    
    func initPresenter() {
        presenter = MarketPulseWidgetPresenter()
        presenter.interactor = MarketPulseWidgetInteractor()
    }
    
    private func initSDK() {
        WavesSDK.initialization(servicesPlugins: .init(data: [],
                                                       node: [],
                                                       matcher: []),
                                enviroment: .init(server: .mainNet, timestampServerDiff: 0))
        
    }
}

//MARK: - FeedBack

extension MarketPulseWidgetViewController {
    
    
    func setupFeedBack() {
        
        let readyViewFeedback: MarketPulseWidgetPresenter.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self.rx.viewWillAppear.take(1).map { _ in MarketPulse.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        
        let feedback = bind(self) { owner, state -> Bindings<MarketPulse.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state),
                            events: [owner.sendEvent.asSignal()])
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback],
                         settings: .init(currency: currency, isDarkMode: isDarkMode))
    }
    
    func subscriptions(state: Driver<MarketPulse.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let self = self else { return }
                
                switch state.action {
                    
                case .update:
                    self.items = state.models
                    self.tableView.reloadData()
                    self.updateBigPrefferedSize()
                    self.hideUpdateAnimation()
                    
                case .didFailUpdate(let error):
                    self.hideUpdateAnimation()
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}

//MARK: - UI
private extension MarketPulseWidgetViewController {
    
    func showUpdateAnimation() {
        if buttonUpdate.imageView?.layer.animation(forKey: Constants.animationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue =  Float.pi * 2.0
            rotationAnimation.duration = Constants.animationDuration
            rotationAnimation.repeatCount = Float.infinity
            
            buttonUpdate.imageView?.layer.add(rotationAnimation, forKey: Constants.animationKey)
        }
    }
    
    func hideUpdateAnimation() {
        buttonUpdate.imageView?.layer.removeAnimation(forKey: Constants.animationKey)
    }
    
    var titleTextColor: UIColor {
        return isDarkMode ? .disabled700 : .basic700
    }
    
    func setupDarkMode() {
        buttonSettings.tintColor = titleTextColor
        buttonUpdate.tintColor = titleTextColor
        viewDarkMode.isHidden = !isDarkMode
    }
    
    func setupButtonUpdateSize() {
        guard let font = buttonUpdate.titleLabel?.font else { return }
        let title = buttonUpdate.title(for: .normal) ?? ""
        let size = title.maxWidth(font: font)
        buttonUpdateWidth.constant = size + Constants.buttonUpdateOffset
    }
    
    func setupCurrencyTitle() {
        
        let selectedColor: UIColor = isDarkMode ? .disabled400 : .disabled900
        
        let text = MarketPulse.Currency.usd.title + " / " + MarketPulse.Currency.eur.title
        let attr = NSMutableAttributedString.init(string: text,
                                                  attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                               NSAttributedString.Key.foregroundColor : titleTextColor])
        attr.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium),
                            NSAttributedString.Key.foregroundColor : selectedColor],
                           range: (text as NSString).range(of: currency.title))
        buttonCurrency.setAttributedTitle(attr, for: .normal)
    }
}

//MARK: - UITableViewDelegate
extension MarketPulseWidgetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketPulseWidgetCell.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}

//MARK: - UITableViewDataSource
extension MarketPulseWidgetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = items[indexPath.row]
        
        switch row {
        case .model(let model):
            let cell = tableView.dequeueCell() as MarketPulseWidgetCell
            cell.update(with: model)
            return cell
        }
    }
}

//MARK: - NCWidgetProviding
extension MarketPulseWidgetViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        else {
            updateBigPrefferedSize()
        }
    }
    
    func updateBigPrefferedSize() {
        
        if extensionContext?.widgetLargestAvailableDisplayMode == .expanded {
            let maxSize = self.extensionContext?.widgetMaximumSize(for: .expanded) ?? .zero
            let height = CGFloat(items.count) * MarketPulseWidgetCell.viewHeight() + Constants.bottomViewHeight
            preferredContentSize = .init(width: maxSize.width, height: height)
        }
    }
}
