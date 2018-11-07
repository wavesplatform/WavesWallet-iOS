//
//  DexSortViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift


fileprivate enum Constants {
    static let contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
}

final class DexSortViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: DexSortPresenterProtocol!
    private var modelSection = DexSort.ViewModel.Section(items: [])
    private let sendEvent: PublishRelay<DexSort.Event> = PublishRelay<DexSort.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        title = Localizable.Waves.Dexsort.Navigationbar.title
        tableView.setEditing(true, animated: false)
        tableView.contentInset = Constants.contentInset

        let feedback = bind(self) { owner, state -> Bindings<DexSort.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: DexSortPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexSort.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
}
    
// MARK: Feedback

fileprivate extension DexSortViewController {
    func events() -> [Signal<DexSort.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexSort.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                
                strongSelf.modelSection = state.section
                guard state.action != .none else { return }
                
                strongSelf.updateUI(state: state)
            })
        
        return [subscriptionSections]
    }
}

//MARK: - SetupUI

private extension DexSortViewController {
    
    func updateUI(state: DexSort.State) {
        if state.action == .delete {
            let indexPath = IndexPath(row: state.deletedIndex, section: 0)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.tableView.reloadData()
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
            CATransaction.commit()
        }
        else {
            tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate
extension DexSortViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    // MARK: Draging cells

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        sendEvent.accept(.dragModels(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath))
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

//MARK: - UITableViewDataSource
extension DexSortViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelSection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = modelSection.items[indexPath.row]
        
        switch row {
        case .model(let model):
           
            let cell = tableView.dequeueCell() as DexSortCell
            cell.update(with: model)
            cell.buttonDeleteDidTap = { [weak self] in
                self?.buttonDeleteDidTap(indexPath)
            }
            
            return cell
        }
    }

}

//MARK: - DexSortingCellActions

private extension DexSortViewController {
    
    func buttonDeleteDidTap(_ indexPath: IndexPath) {
        sendEvent.accept(.tapDeleteButton(indexPath))
    }
}


