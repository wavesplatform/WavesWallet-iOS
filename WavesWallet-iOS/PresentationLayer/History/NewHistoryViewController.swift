//
//  NewHistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class NewHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let displays: [HistoryTypes.Display] = [.all, .sent, .received, .exchanged, .leased, .issued, .activeNow, .canceled]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}

// MARK: Setup Methods

private extension NewHistoryViewController {
    
    func setupTableView() {
        
    }
    
}

extension NewHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension NewHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WalletAssetSkeletonCell = tableView.dequeueCell()
        
        return cell
    }
    
}
