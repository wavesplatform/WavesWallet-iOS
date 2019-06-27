//
//  WalletSearchViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift
import DomainLayer

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let searchIconFrame: CGRect = .init(x: 0, y: 0, width: 36, height: 24)
    static let deltaButtonWidth: CGFloat = 16
    static let contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0)
    static let searchBarTopDiff: CGFloat = 6
    
    enum Shadow {
        static let height: CGFloat = 4
        static let opacity: Float = 0.1
        static let radius: Float = 3
    }
}

protocol WalletSearchViewControllerDelegate: AnyObject {

    func walletSearchViewControllerDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance])
    func walletSearchViewControllerDidTapCancel(_ searchController: WalletSearchViewController)
}

final class WalletSearchViewController: UIViewController  {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonCancel: UIButton!
    @IBOutlet private weak var buttonCancelWidth: NSLayoutConstraint!
    @IBOutlet private weak var buttonCancelPosition: NSLayoutConstraint!
    @IBOutlet private weak var searchBarContainer: UIView!
    
    private var startPosition: CGFloat = 0
    private let sendEvent: PublishRelay<WalletSearch.Event> = PublishRelay<WalletSearch.Event>()
    private var sections: [WalletSearch.ViewModel.Section] = []
    private var assets: [DomainLayer.DTO.SmartAssetBalance] = []
    
    var presenter: WalletSearchPresenterProtocol!
    weak var delegate: WalletSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFeedBack()
        setupSearchBar()
        setupButtonCancel()
        view.alpha = 0
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = Constants.contentInset
        textFieldSearch.addTarget(self, action: #selector(textFieldSearchDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldSearchDidChange() {
        sendEvent.accept(.search(textFieldSearch.text ?? ""))
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        delegate?.walletSearchViewControllerDidTapCancel(self)
    }
    
    func dismiss() {
        buttonCancelPosition.constant = -buttonCancelWidth.constant
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.viewContainer.frame.origin.y = self.startPosition
            self.view.layoutIfNeeded()
            self.view.alpha = 0
        }) { (complete) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func showWithAnimation(fromStartPosition: CGFloat) {
        startPosition = fromStartPosition - Constants.searchBarTopDiff
        
        let startOffset = viewContainer.frame.origin.y
        viewContainer.frame.origin.y = startPosition 
        buttonCancelPosition.constant = 0
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.view.alpha = 1
            self.view.layoutIfNeeded()
            self.viewContainer.frame.origin.y = startOffset
        }) { (complete) in
            self.textFieldSearch.becomeFirstResponder()
        }
    }
}

//MARK: - RXFeedBack
private extension WalletSearchViewController {
    
    func setupFeedBack() {
        let feedback = bind(self) { owner, state -> Bindings<WalletSearch.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state),
                            events: owner.events())
        }
        
        let readyViewFeedback: WalletSearchPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in WalletSearch.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<WalletSearch.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<WalletSearch.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let self = self else { return }
                
                if state.action == .none {
                    return
                }
                
                self.sections = state.sections
                self.assets = state.assets
                self.tableView.contentInset.top = state.hasGeneralAssets ? Constants.contentInset.top : 0
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.tableView.setContentOffset(.init(x: 0, y: -self.tableView.contentInset.top), animated: false)
                }
            })
        
        return [subscriptionSections]
    }
}


//MARK: - UI
private extension WalletSearchViewController {
    
    func setupButtonCancel() {
        let buttonTitle = Localizable.Waves.Walletsearch.Button.cancel
        buttonCancel.setTitle(buttonTitle, for: .normal)
        
        guard let font = buttonCancel.titleLabel?.font else { return }
        buttonCancelWidth.constant = buttonTitle.maxWidth(font: font) + Constants.deltaButtonWidth
        buttonCancelPosition.constant = -buttonCancelWidth.constant
    }
    
    func setupSearchBar() {
        
        let imageView = UIImageView(image: Images.search24Black.image)
        imageView.frame = Constants.searchIconFrame
        imageView.contentMode = .center
        textFieldSearch.leftView = imageView
        textFieldSearch.leftViewMode = .always
        textFieldSearch.placeholder = nil
        
        searchBarContainer.backgroundColor = .basic50
        searchBarContainer.layer.setupShadow(options: .init(offset: CGSize(width: 0, height: Constants.Shadow.height),
                                                            color: .black,
                                                            opacity: Constants.Shadow.opacity,
                                                            shadowRadius: Constants.Shadow.radius,
                                                            shouldRasterize: true))
    }
}

//MARK: - UITableViewDelegate
extension WalletSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].items[indexPath.row]
        switch row {
        case .asset(let asset):
            delegate?.walletSearchViewControllerDidSelectAsset(asset, assets: assets)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = sections[indexPath.section]
        let row = section.items[indexPath.row]
        switch row {
        case .asset:
            return WalletTableAssetsCell.cellHeight()
            
        case .header:
            return WalletSearchHeaderCell.viewHeight()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
}

//MARK: - UITableViewDataSource
extension WalletSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .asset(let asset):
            let cell = tableView.dequeueAndRegisterCell() as WalletTableAssetsCell
            cell.update(with: asset)
            return cell
            
        case .header(let kind):
            let cell = tableView.dequeueAndRegisterCell() as WalletSearchHeaderCell
            cell.update(with: kind)
            return cell
        }
    }
}
