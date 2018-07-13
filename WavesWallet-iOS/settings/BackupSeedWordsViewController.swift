//
//  BackupSeedWordsViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 26/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WordCollectionCell: UICollectionViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    
    func bindItem(_ item: String) {
        wordLabel.text = item
    }
}

class BackupSeedWordsViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var startVc: UIViewController!
    var words = [String]()
    var currentWordIdx: Variable<Int> = Variable(0)
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let cv = self.collectionView
            , let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            cv.backgroundColor = AppColors.wavesColor
            cv.alwaysBounceVertical = false
            cv.showsHorizontalScrollIndicator = false
            cv.isPagingEnabled = true
            cv.showsVerticalScrollIndicator = false
            cv.showsHorizontalScrollIndicator = false
            
            // Layout
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        fetchWords()
        collectionView.delegate = self
        
        currentWordIdx.asDriver().map{ "Word \($0 + 1) of \(self.words.count)" }
            .drive(wordsCountLabel.rx.text)
            .disposed(by: bag)
        
        currentWordIdx.asDriver().map { $0 == (self.words.count - 1) && self.words.count >= 3 }
            .drive(submitButton.rx.isEnabled)
            .disposed(by: bag)
        
    }

    func fetchWords() {
        WalletManager.restorePrivateKey()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { pk in
                self.words = pk.words
                self.collectionView?.reloadData()
                self.currentWordIdx.value = 0
            }, onError: { err in
                self.presentBasicAlertWithTitle(title: err.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WordCollectionCell
        
        cell.bindItem(words[indexPath.row])
        return cell
    }

    var isSliding = false

    @IBAction func onSlideLeft(_ sender: Any) {
        if isSliding { return }
        
        if let cv = collectionView
            , let cur = cv.indexPathsForVisibleItems.min()
            , words.count > 1 {
            
            let next = IndexPath(item: max(0, cur.item - 1), section: cur.section)
            cv.scrollToItem(at: next, at: .left, animated: true)
            isSliding = true
        }
    }
    
    @IBAction func onSlideRight(_ sender: Any) {
        if isSliding { return }
        
        if let cv = collectionView
            , let cur = cv.indexPathsForVisibleItems.min()
            , words.count > 1
            , cur.item < words.count - 1 {
            
            let next = IndexPath(item: (cur.item + 1) % words.count, section: cur.section)
            cv.scrollToItem(at: next, at: .left, animated: true)
            isSliding = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentWord()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentWord()
    }

    func updateCurrentWord() {
        let curIdx = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        currentWordIdx.value = curIdx
        isSliding = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BackupVerifyViewController {
            vc.startVc = self.startVc
            vc.words = self.words
        }
    }

}

extension BackupSeedWordsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
