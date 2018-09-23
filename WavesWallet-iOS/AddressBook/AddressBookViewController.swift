//
//  AddressBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

final class AddressBookViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: SearchBarView!
    @IBOutlet private weak var labelNoInfo: UILabel!
    @IBOutlet private weak var viewNoInfo: UIView!
    
    weak var delegate: AddressBookModuleOutput?
    var isEditMode: Bool = false
    
    var presenter: AddressBookPresenterProtocol!
    private var modelSection = AddressBook.ViewModel.Section(items: [])
    private let sendEvent: PublishRelay<AddressBook.Event> = PublishRelay<AddressBook.Event>()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarAddaddress.image, style: .plain, target: self, action: #selector(addUserTapped))
        setupLocalization()
        createBackButton()
        setupFeedBack()
        tableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
}

//MARK: - UI

private extension AddressBookViewController {
    
    func setupLocalization() {
        title = Localizable.AddressBook.Label.addressBook
        labelNoInfo.text = Localizable.AddressBook.Label.noInfo
    }

    func setupUIState() {
        viewNoInfo.isHidden = !modelSection.isEmpty
        tableView.isHidden = modelSection.isEmpty
        searchBar.isHidden = modelSection.isEmpty
    }
}

//MARK: - Actions
private extension AddressBookViewController {
    
    @objc func addUserTapped() {
        
    }
}

// MARK: Feedback

private extension AddressBookViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<AddressBook.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: AddressBookPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in AddressBook.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<AddressBook.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<AddressBook.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                strongSelf.modelSection = state.section
                strongSelf.tableView.reloadData()
                strongSelf.setupUIState()
            })
        
        return [subscriptionSections]
    }
}


//MARK: - SearchBarViewDelegate
extension AddressBookViewController: SearchBarViewDelegate {
    
    func searchBarDidChangeText(_ searchText: String) {
        sendEvent.accept(.searchTextChange(text: searchText))
    }
}

//MARK: - UITableViewDelegate
extension AddressBookViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isEditMode == false else { return }
        let user = modelSection.items[indexPath.row].user
        delegate?.addressBookDidSelectUser(user)
    }
}

//MARK: - UITableViewDataSource
extension AddressBookViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelSection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueCell() as AddressBookCell
        let user = modelSection.items[indexPath.row].user
        cell.update(with: .init(user: user, isEditMode: isEditMode))
        cell.delegate = self
        return cell
    }
}

extension AddressBookViewController: AddressBookCellDelegate {
    
    func addressBookCellDidTapEdit(_ cell: AddressBookCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            
            let user = modelSection.items[indexPath.row].user
            delegate?.addressBookDidEditUser(user)
        }
    }
}
