//
//  AddressesKeysViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AddressesKeysViewController: UIViewController {

    typealias Types = AddressesKeysTypes

    @IBOutlet private var tableView: UITableView!

    private var sections: [Types.ViewModel.Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        sections = [Types.ViewModel.Section.init(rows: [.aliases,
                                                        .address,
                                                        .publicKey,
                                                        .hiddenPrivateKey])]
    }
}


// MARK: UITableViewDataSource

extension AddressesKeysViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

}

// MARK: UITableViewDelegate

extension AddressesKeysViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = sections[indexPath]
        switch row {
        case .address:
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            return cell

        case .aliases:
            let cell: AddressesKeysAliacesCell = tableView.dequeueCell()
            return cell

        case .hiddenPrivateKey:
            let cell: AddressesKeysHiddenPrivateKeyCell = tableView.dequeueCell()
            return cell

        case .privateKey:
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            return cell

        case .publicKey:
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            return cell
        }

    }
}
