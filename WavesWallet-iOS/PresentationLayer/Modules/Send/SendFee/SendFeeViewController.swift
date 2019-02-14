//
//  SendFeeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxCocoa
import RxSwift


final class SendFeeViewController: ModalScrollViewController {
    
    weak var delegate: SendFeeModuleOutput!
    var presenter: SendFeePresenterProtocol!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var sections: [SendFee.ViewModel.Section] = []
    private let sendEvent: PublishRelay<SendFee.Event> = PublishRelay<SendFee.Event>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFeedBack()
    }

    override var scrollView: UIScrollView {
        return self.tableView
    }

    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return 288
    }
}


//MARK: - FeedBack
private extension SendFeeViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<SendFee.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<SendFee.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<SendFee.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let owner = self else { return }
                switch state.action {
                case .none:
                    return
                
                case .update:
                    owner.sections = state.sections
                    owner.tableView.reloadData()
                    owner.activityIndicator.stopAnimating()
                    
                case .handleError(let error):
                    owner.activityIndicator.stopAnimating()
                    owner.showNetworkErrorSnack(error: error)
                }
            })
        
        return [subscriptionSections]
    }
}


//MARK: - UITableViewDelegate
extension SendFeeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .asset(let asset):
            if !asset.isActive {
                return
            }
            delegate.sendFeeModuleDidSelectAssetFee(asset.assetBalance, fee: asset.fee)
            if let vc = parent as? PopupViewController {
                vc.dismissPopup()
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDataSource
extension SendFeeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SendFeeHeaderView.viewHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sendFeeHeaderView: SendFeeHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        return sendFeeHeaderView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .header:
            return UITableViewCell()
            
        case .asset(let asset):
            let cell = tableView.dequeueCell() as SendFeeTableViewCell
            cell.update(with: asset)
            return cell
        }
    }
}
