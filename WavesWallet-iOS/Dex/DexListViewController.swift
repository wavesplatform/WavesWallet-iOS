//
//  DexListViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(8, 0, 0, 0)
}

final class DexListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNoItems: UIView!
    
    private let dataContainer = DexDataContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton()
        title = "Dex"
        tableView.contentInset = Constants.contentInset
        
        dataContainer.delegate = self
        dataContainer.simulateDataFromServer()

        setupViews()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }

   
    //MARK: - Actions
    @objc func sortTapped() {
    
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DexSearchViewController") as! DexSearchViewController
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: SetupUI
extension DexListViewController {

    func setupViews() {
        viewNoItems.isHidden = dataContainer.models.count > 0 || dataContainer.state == .isLoading
    }
    
    func setupButtons() {
        
        let btnAdd = UIBarButtonItem(image: UIImage(named: "topbarAddmarkets"), style: .plain, target: self, action: #selector(addTapped(_:)))
        let buttonSort = UIBarButtonItem(image: UIImage(named: "topbarSort"), style: .plain, target: self, action: #selector(sortTapped))
        
        if dataContainer.state == .isLoading {
            btnAdd.isEnabled = false
            buttonSort.isEnabled = false
            navigationItem.rightBarButtonItems = [btnAdd, buttonSort]
        }
        else if dataContainer.models.count > 0{
            navigationItem.rightBarButtonItems = [btnAdd, buttonSort]
        }
        else {
            navigationItem.rightBarButtonItem = btnAdd
        }
    }    
}

//MARK: DexDataContainerDelegate
extension DexListViewController: DexDataContainerDelegate {
    
    func dexDataContainerDidUpdateModels(_ dataContainer: DexDataContainer, models: [DexListModel]) {
        tableView.reloadData()
        setupViews()
        setupButtons()
    }
}

//MARK: - UITableViewDelegate
extension DexListViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataContainer.state == .isLoading {
            return
        }
        
    }
}

//MARK: - UITableViewDataSource
extension DexListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataContainer.countSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataContainer.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataContainer.state == .isLoading {
            return tableView.dequeueCell() as DexListSkeletonCell
        }
        
        let cell: DexListCell = tableView.dequeueCell()
        cell.setupCell(dataContainer.modelForIndexPath(indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if dataContainer.state == .isLoading {
            let skeletonCell: DexListSkeletonCell = cell as! DexListSkeletonCell
            skeletonCell.slide(to: .right)
        }
    }
   
}
