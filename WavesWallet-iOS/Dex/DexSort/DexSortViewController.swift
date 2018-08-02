//
//  DexSortViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
}

final class DexSortViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        title = "Sorting"
        tableView.setEditing(true, animated: false)
        tableView.contentInset = Constants.contentInset
    }
}

//MARK: - UITableViewDelegate
extension DexSortViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - UITableViewDataSource
extension DexSortViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell() as DexSortingCell
        cell.delegate = self
        return cell
    }
}

//MARK: - DexSortingCellDelegate
extension DexSortViewController : DexSortingCellDelegate {
    
}
