//
//  DexViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 04.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class DexTableListCell : UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContent.layer.cornerRadius = 3
    }
}

class DexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dex"
        navigationController?.navigationBar.barTintColor = AppColors.dexNavBarColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        self.performSegue(withIdentifier: "DexContainerViewController", sender: nil)
    }
    
    func addTapped() {
        
    }
    
    //MARK: UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "DexContainerViewController", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell : DexTableListCell = tableView.dequeueReusableCell(withIdentifier: "DexTableListCell", for:indexPath) as! DexTableListCell
       
        return cell
    }
    
    //MARK: Segue
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DexContainerViewController" {
            
            let indexPath = sender
            let DexContainerViewController = segue.destination
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
