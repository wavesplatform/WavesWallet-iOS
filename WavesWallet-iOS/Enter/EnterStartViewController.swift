//
//  EnterStartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import SwipeView
import RESideMenu


class EnterStartCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
}

class EnterStartViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SwipeViewDelegate, SwipeViewDataSource {
    
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionTopOffset: NSLayoutConstraint!
    @IBOutlet weak var swipeView: SwipeView!
    
    @IBOutlet weak var swipeViewOffset: NSLayoutConstraint!
    
    @IBOutlet weak var buttonLanguage: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    let iconNames = ["userimgBlockchain80White", "userimgWallet80White", "userimgDex80White", "userimgToken80White"]
    var currentPage: Int = 0

    let items = [["title" : "Get Started with Blockchain", "text" : "Become part of a fast-growing area of the crypto world. You are the only person who can access your crypto assets."],
                 ["title" : "Wallet", "text" : "Store, manage and receive interest on your digital assets balance, easily and securely."],
                 ["title" : "Decentralised Exchange", "text" : "Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange."],
                 ["title" : "Token Launcher", "text" : "Issue your own tokens. These can be integrated into your business not only as an internal currency but also as a token for decentralised voting, as a rating system, or loyalty program."]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeView.delegate = self
        swipeView.dataSource = self
        
        addBgBlueImage()
        
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 24)
        
        if Platform.isIphone5 {
            collectionTopOffset.constant = 0
            collectionViewHeight.constant = 80
            swipeViewOffset.constant = 24
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func changeLanguage(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "EnterLanguageViewController") as! EnterLanguageViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func signInAccount(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "EnterSelectAccountViewController") as! EnterSelectAccountViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func importAccount(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "ImportAccountViewController") as! ImportAccountViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func createNewAccountTapped(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountViewController") as! NewAccountViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let menu = AppDelegate.shared().window?.rootViewController as! RESideMenu
        menu.presentLeftMenuViewController()
    }
    
    //MARK: - SwipeView
    
    //MARK: - SwipeViewDelegate
    
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {

        if currentPage != swipeView.currentPage {
            currentPage = swipeView.currentPage
            collectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return items.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var contentView : EnterStartView! = view as? EnterStartView
        
        if contentView == nil {
            contentView = EnterStartView.loadView() as? EnterStartView
            contentView.frame = swipeView.bounds
            contentView.labelTitle.textColor = .white
            contentView.labelDescription.textColor = .white
        }
        
        let item = items[index]
        contentView.labelTitle.text = item["title"]
        contentView.labelDescription.text = item["text"]
        
        return contentView
    }
    
    //MARK: - UICollectionView
    
    fileprivate var collectionPageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnterStartCollectionCell", for: indexPath) as! EnterStartCollectionCell
        
        cell.imageIcon.image = UIImage(named: iconNames[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row != currentPage {
            currentPage = indexPath.row
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            swipeView.scroll(toPage: currentPage, duration: 0.35)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let newPage = Int(floor((scrollView.contentOffset.x - collectionPageSize.width / 2) / collectionPageSize.width) + 1)
            if currentPage != newPage {
                currentPage = newPage
                swipeView.scroll(toPage: currentPage, duration: 0.35)
            }
        }
    }
    
}
