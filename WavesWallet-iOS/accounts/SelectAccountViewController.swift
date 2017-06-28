//
//  SelectAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 05/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

private let reuseIdentifier = "cell"

class SelectAccountViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    let bag = DisposeBag()
    var selectedAccount: Variable<AssetBalance?> = Variable(nil)
    
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
        
        fetchAccounts()
        collectionView.delegate = self
    }
    
    func index(of ab: AssetBalance) -> Int {
        if (accounts.count > 1) {
            if let i = accounts.index(of: ab) {
                if i == 0 { return accounts.count - 2 }
                else if i == accounts.count - 1 { return 1 }
                else { return i }
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    func index(ofId assetId: String) -> Int {
        if (accounts.count > 1) {
            if let i = accounts.index(where: { $0.assetId == assetId }) {
                if i == 0 { return accounts.count - 2 }
                else if i == accounts.count - 1 { return 1 }
                else { return i }
            } else {
                return 1
            }
        } else {
            return 0
        }
    }

    func findAssetBalance(assetId: String) -> AssetBalance? {
        return accounts.first(where: { $0.assetId == assetId})
    }
    
    func indexPath(of ab: AssetBalance) -> IndexPath {
        return IndexPath(item: index(of: ab), section: 0)
    }
    
    func indexPath(ofId assetId: String) -> IndexPath {
        return IndexPath(item: index(ofId: assetId), section: 0)
    }
    
    
    var accounts = [AssetBalance]()
    
    func fetchAccounts() {
        let realm = try! Realm()
        let rAccounts = realm.objects(AssetBalance.self).filter("isHidden == false")
        
        Observable.array(from: rAccounts)//.observeOn(MainScheduler.instance)
            .subscribe(onNext: { results in
                self.accounts = results
                if results.count > 1 {
                    self.accounts.insert(results.last!, at: 0)
                    self.accounts.append(results[0])
                }
                self.collectionView?.reloadData()
                
                DispatchQueue.main.async {
                    if let cur = self.selectedAccount.value {
                        self.collectionView?.scrollToItem(at: self.indexPath(of: cur), at: .left, animated: false)
                        self.selectedAccount.value = cur
                    } else {
                        let first = self.accounts.count > 1 ? 1 : 0
                        let i = IndexPath(item: first, section: 0)
                        self.collectionView?.scrollToItem(at: i, at: .left, animated: false)
                        self.selectedAccount.value = self.accounts[first]
                    }
                }
            })
            .addDisposableTo(bag)
        
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func item(_ indexPath: IndexPath) -> AssetBalance? {
        return accounts[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectAccountCollectionCell
        
        cell.bindItem(item(indexPath))
        return cell
    }
    
   
    func updateSelectedAccount() {
        if let cv = collectionView {
            let curIdx = Int(cv.contentOffset.x / cv.frame.size.width)
            selectedAccount.value = item(IndexPath(item: curIdx, section: 0))
        }
    }
    
    var isSliding = false
    
    func itemsCount() -> Int {
        return accounts.count
    }
    
    @IBAction func onSlideLeft(_ sender: Any) {
        if isSliding { return }
        
        if let cv = collectionView
            , let cur = cv.indexPathsForVisibleItems.min()
            , itemsCount() > 1 {
            
            let next = IndexPath(item: max(0, cur.item - 1), section: cur.section)
            cv.scrollToItem(at: next, at: .left, animated: true)
            isSliding = true
        }
    }
    
    @IBAction func onSlideRight(_ sender: Any) {
        if isSliding { return }
        
        if let cv = collectionView
            , let cur = cv.indexPathsForVisibleItems.min()
            , itemsCount() > 1  {
            
            let next = IndexPath(item: (cur.item + 1) % itemsCount(), section: cur.section)
            cv.scrollToItem(at: next, at: .left, animated: true)
            isSliding = true
        }
    }
    
    func adjustContentOffset() {
        if let cv = collectionView {
            let contentOffsetWhenFullyScrolledRight = cv.frame.size.width * CGFloat(itemsCount() - 1)
            
            if (cv.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
                
                // user is scrolling to the right from the last item to the 'fake' item 1.
                // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
                let newIndexPath = IndexPath(item: 1, section: 0)
                cv.scrollToItem(at: newIndexPath, at: .left, animated: false)
                
            } else if (cv.contentOffset.x == 0)  {
                
                // user is scrolling to the left from the first item to the fake 'item N'.
                // reposition offset to show the 'real' item N at the right end end of the collection view
                let newIndexPath = IndexPath(item: itemsCount() - 2, section: 0)
                cv.scrollToItem(at: newIndexPath, at: .left, animated: false)
            }
        }
        isSliding = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustContentOffset()
        updateSelectedAccount()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustContentOffset()
        updateSelectedAccount()
    }
    
    func scrollToCurrent(cur: AssetBalance?) {
        DispatchQueue.main.async {
            if let cur = cur {
                self.collectionView?.scrollToItem(at: self.indexPath(of: cur), at: .left, animated: false)
                self.selectedAccount.value = cur
            } else {
                let first = self.accounts.count > 1 ? 1 : 0
                let i = IndexPath(item: first, section: 0)
                self.collectionView?.scrollToItem(at: i, at: .left, animated: false)
                self.selectedAccount.value = self.accounts[first]
            }
        }
    }
    
    func selectAccount(assetId: String) -> AssetBalance? {
        let ab = findAssetBalance(assetId: assetId)
        self.selectedAccount.value = ab
        scrollToCurrent(cur: ab)
        return ab
    }


}

extension SelectAccountViewController: UICollectionViewDelegateFlowLayout {
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

