//
//  BackupVerifyViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 26/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm

class BackupVerifyViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var sumbitButton: UIButton!
    
    var words = [String]()
    var startVc: UIViewController!
    var chosenWordsIdx = [Int]()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillChosen()
        setupPlaceholders()
        
        let inputValue: Driver<(String, String, String)> =
            Driver.combineLatest(firstField.rx.text.orEmpty.asDriver(),
                                 secondField.rx.text.orEmpty.asDriver(),
                                 thirdField.rx.text.orEmpty.asDriver()) { ($0, $1, $2) }
        
        inputValue.map{ !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
            .drive(sumbitButton.rx.isEnabled)
            .disposed(by: bag)
        
        sumbitButton.rx.tap.asObservable()
            .withLatestFrom(inputValue.asObservable())
            .subscribe(onNext: { three in
                let _1 = three.0 == self.words[self.chosenWordsIdx[0]]
                if !_1 { self.firstField.textColor = .red }
                let _2 = three.1 == self.words[self.chosenWordsIdx[1]]
                if !_2 { self.secondField.textColor = .red }
                let _3 = three.2 == self.words[self.chosenWordsIdx[2]]
                if !_3 { self.thirdField.textColor = .red }
                
                if _1 && _2 && _3 {
                    self.verifyCompleted()
                } else {
                    self.presentBasicAlertWithTitle(title: "Incorrect input")
                }
            })
            .disposed(by: bag)
    }
    
    func verifyCompleted() {
        let realm = WalletManager.getWalletsRealm()
        try! realm.write {
            realm.create(WalletItem.self, value: ["publicKey": WalletManager.currentWallet!.publicKeyStr, "isBackedUp": true], update: true)
        }
        WalletManager.currentWallet!.isBackedUp = true
        if let items = self.tabBarController?.tabBar.items {
            items[4].badgeValue = nil
        }
        self.navigationController?.popToViewController(startVc, animated: true)
    }
    
    func fillChosen() {
        for i in 0..<3 {
            repeat {
                let r = Int(arc4random_uniform(UInt32(words.count)))
                if chosenWordsIdx.endIndex == i {
                    chosenWordsIdx.append(r)
                } else {
                    chosenWordsIdx[i] = r
                }
            } while isDuplicatesExist(array: chosenWordsIdx)
        }
        chosenWordsIdx.sort()
    }

    let indexName = ["first", "second", "third"]
    
    func setupPlaceholders() {
        firstField.delegate = self
        secondField.delegate = self
        thirdField.delegate = self
        
        firstField.placeholder = (indexName[safe: chosenWordsIdx[0]] ?? "\(chosenWordsIdx[0] + 1)th") + " word"
        secondField.placeholder = (indexName[safe: chosenWordsIdx[1]] ?? "\(chosenWordsIdx[1] + 1)th") + " word"
        thirdField.placeholder = (indexName[safe: chosenWordsIdx[2]] ?? "\(chosenWordsIdx[2] + 1)th") + " word"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.textColor = AppColors.darkGreyText
        return true
    }

}

func isDuplicatesExist(array: [Int]) -> Bool {
    var duplicates = Set<Int>()
    
    for i in array {
        if duplicates.contains(i) { return true }
        
        duplicates.insert(i)
    }
    
    return false
}
