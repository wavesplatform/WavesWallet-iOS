//
//  WalletSortViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletSortSeparatorCell: UITableViewCell {
    
    class func cellHeight() -> CGFloat {
        return 26
    }
}

class WalletSortCell: UITableViewCell {
 
    @IBOutlet weak var buttonFav: UIButton!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var arrowGreen: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconMenu: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var viewContent: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 56
    }
    
    func setupCellState(isVisibility: Bool) {
        switchControl.alpha = isVisibility ? 1 : 0
        iconMenu.alpha = isVisibility ? 0 : 1
        
        iconMenu.alpha = 0
    }
}

class WalletSortFavCell: UITableViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var buttonFav: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconLock: UIImageView!
    @IBOutlet weak var arrowGreen: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    
    class func cellHeight() -> CGFloat {
        return 48
    }
    
    func setupCellState(isVisibility: Bool) {
        switchControl.alpha = isVisibility ? 1 : 0
    }
}


class WalletSortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    enum Section: Int {
        case fav = 0
        case separator
        case sort
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var isVisibilityMode = false


    var favItems = ["Waves", "Bitcoin", "ETH", "ETH Classic", "Ripple"]
    var sortItems = ["Bitcoin Cash", "EOS", "Cardano", "Stellar", "Litecoin", "NEO", "TRON", "Monero", "ZCash"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sorting"
        
        createBackButton()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Visibility", style: .plain, target: self, action: #selector(changeStyle))

        tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)
        hideTopBarLine()
        tableView.isEditing = true
    }
    
    func changeStyle() {
        
        isVisibilityMode = !isVisibilityMode
        navigationItem.rightBarButtonItem?.title = isVisibilityMode ? "Position" : "Visibility"
    
        UIView.animate(withDuration: 0.3) {
            
            for tableCell in self.tableView.visibleCells {
                if let cell = tableCell as? WalletSortCell {
                    cell.setupCellState(isVisibility: self.isVisibilityMode)
                }
                else if let cell = tableCell as? WalletSortFavCell {
                    let indexPath = self.tableView.indexPath(for: cell)
                    if indexPath?.row != 0 {
                        cell.setupCellState(isVisibility: self.isVisibilityMode)
                    }
                }
            }
        }
        tableView.setEditing(!isVisibilityMode, animated: true)
    }

    
    func addToFavourite(_ sender: UIButton) {
     
        let index = sender.tag
        let string = sortItems[index]
        sortItems.remove(at: index)
        favItems.append(string)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableView.reloadData()
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: Section.sort.rawValue)], with: .fade)
        tableView.insertRows(at: [IndexPath(row: favItems.count - 1, section: Section.fav.rawValue)], with: .fade)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func removeFromFavourite( _ sender: UIButton) {
        let index = sender.tag
        
        if index == 0 {
            return
        }
        
        let string = favItems[index]
        favItems.remove(at: index)
        sortItems.insert(string, at: 0)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableView.reloadData()
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: Section.fav.rawValue)], with: .fade)
        tableView.insertRows(at: [IndexPath(row: 0, section: Section.sort.rawValue)], with: .fade)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    //MARK: - UITableView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {

        if proposedDestinationIndexPath.section == Section.fav.rawValue ||
           proposedDestinationIndexPath.section == Section.separator.rawValue {
            return IndexPath(row: 0, section: Section.sort.rawValue)
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
     
        let stringToMove = sortItems[sourceIndexPath.row]
        sortItems.remove(at: sourceIndexPath.row)
        sortItems.insert(stringToMove, at: destinationIndexPath.row)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableView.reloadData()
        }
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        CATransaction.commit()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == Section.sort.rawValue {
            return !isVisibilityMode
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.fav.rawValue {
            return WalletSortFavCell.cellHeight()
        }
        else if indexPath.section == Section.sort.rawValue {
            return WalletSortCell.cellHeight()
        }
        
        return sortItems.count > 0 ? WalletSortSeparatorCell.cellHeight() : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == Section.fav.rawValue {
            return favItems.count
        }
        else if section == Section.sort.rawValue {
            return sortItems.count
        }
        else if section == Section.separator.rawValue {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if indexPath.section == Section.fav.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletSortFavCell") as! WalletSortFavCell
            cell.buttonFav.tag = indexPath.row
            cell.buttonFav.addTarget(self, action: #selector(removeFromFavourite(_:)), for: .touchUpInside)
            
            cell.labelTitle.text = favItems[indexPath.row]
            cell.setupCellState(isVisibility: isVisibilityMode)

            cell.iconLock.isHidden = true            
            if indexPath.row == 0 {
                cell.switchControl.alpha = 0
                cell.iconLock.isHidden = false
            }
            
            return cell
        }
        else if indexPath.section == Section.sort.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletSortCell") as! WalletSortCell
            cell.buttonFav.tag = indexPath.row
            cell.buttonFav.addTarget(self, action: #selector(addToFavourite(_:)), for: .touchUpInside)
            
            cell.labelTitle.text = sortItems[indexPath.row]

            cell.setupCellState(isVisibility: isVisibilityMode)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "WalletSortSeparatorCell") as! WalletSortSeparatorCell
    }

}
