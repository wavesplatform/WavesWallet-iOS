//
//  ViewController.swift
//  testApp
//
//  Created by Pavel Gubin on 5/13/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit


enum Section: Int {
    case banner
    case segmented
    case search
    case tokens
}

enum SegmentedIndex: Int {
    case test = 0
    case test2
    case test3
    case test4
    case test5
    case test6
    case test7
    case test8
    
    var title: String {
        switch self {
        case .test:
            return "test"
            
        case .test2:
            return "test2"
            
        case .test3:
            return "test3"
            
        case .test4:
            return "test4"
            
        case .test5:
            return "test5"
            
        case .test6:
            return "test6"
            
        case .test7:
            return "test7"
            
        case .test8:
            return "test8"
        }
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScrolledContainerViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewCustom: ScrolledContainerView!
    
    private var banners: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test VC"
        
        let topBannerView = Bundle.main.loadNibNamed("TopContainer", owner: self, options: nil)?.last as! TopContainer
        topBannerView.delegate = self
        let topBannerView2 = Bundle.main.loadNibNamed("TopContainer2", owner: self, options: nil)?.last as! TopContainer2
        topBannerView2.delegate = self
      
        
        banners.append(topBannerView)
        banners.append(topBannerView2)

        
        viewCustom.scrollViewDelegate = self
        viewCustom.refreshDidChange = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self?.viewCustom.refreshControl?.endRefreshing()
            })
        }
//        banners = []
        viewCustom.setup(segmentedItems: [SegmentedIndex.test.title,
                                          SegmentedIndex.test2.title,
                                          SegmentedIndex.test3.title,
                                                 SegmentedIndex.test4.title,
                                                 SegmentedIndex.test5.title,
                                                 SegmentedIndex.test6.title,
                                                 SegmentedIndex.test7.title,
                                                 SegmentedIndex.test8.title],
                                topContents: banners,
                                topContentsSectionIndex: Section.banner.rawValue,
                                tableDataSource: self,
                                tableDelegate: self)

        self.view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 251/255, alpha: 1)
        navigationController?.navigationBar.backgroundColor = self.view.backgroundColor
        
        navigationItem.shadowImage = UIImage()
        setupBigNavigationBar()
    }
  
    func searchTapped(_ cell: UITableViewCell) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController

        let rectInTableView = viewCustom.visibleTableView.rectForRow(at: IndexPath.init(row: 0, section: Section.search.rawValue))
        let rectInSuperview = viewCustom.visibleTableView.convert(rectInTableView, to: self.view)
        
        let initialY = rectInSuperview.origin.y
        vc.initialY = initialY

        vc.modalPresentationStyle = .custom;
        vc.view.frame = UIScreen.main.bounds
        vc.view.alpha = 0

        present(vc, animated: false) {
            
            vc.view.alpha = 1
            let startOffset = vc.viewContainer.frame.origin.y
            vc.viewContainer.frame.origin.y = initialY
            vc.searchBar.setShowsCancelButton(true, animated: true)
            vc.searchBar.becomeFirstResponder()

            UIView.animate(withDuration: 0.3, animations: {
                vc.viewContainer.frame.origin.y = startOffset
            }, completion: { (complete) in
                
//                DispatchQueue.main.async {
//                    vc.searchBar.becomeFirstResponder()
//                }
            })
        }
    }
    
    func setupSearchBarOffset() {
        
        if viewCustom.contentOffset.y + viewCustom.smallTopOffset > viewCustom.topOffset &&
            viewCustom.contentOffset.y + viewCustom.smallTopOffset < viewCustom.topOffset + SearchTableViewCell.cellHeight
            && isSmallNavigationBar && viewCustom.visibleTableView.tag == SegmentedIndex.test.rawValue {
        
            
            let diff = (viewCustom.topOffset + SearchTableViewCell.cellHeight) - (viewCustom.contentOffset.y + viewCustom.smallTopOffset)

            var offset: CGFloat = 0
            if diff > SearchTableViewCell.cellHeight / 2 {
                offset = -viewCustom.smallTopOffset
            }
            else {
                offset = -viewCustom.smallTopOffset + SearchTableViewCell.cellHeight
            }
            offset += viewCustom.topOffset
            setupSmallNavigationBar()

            viewCustom.setContentOffset(.init(x: 0, y: offset), animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(viewCustom.visibleTableView.frame.origin.y,
//              viewCustom.visibleTableView.contentOffset.y,
//              viewCustom.contentOffset.y)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == viewCustom {
            setupSearchBarOffset()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == viewCustom {
            if !decelerate {
                setupSearchBarOffset()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.tokens.rawValue {
            let vc = storyboard?.instantiateViewController(withIdentifier: "TestPushViewController") as! TestPushViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.segmented.rawValue {
            return viewCustom.segmentedHeight
        }
        else if indexPath.section == Section.banner.rawValue {
            return banners[indexPath.row].frame.size.height
        }
        else if indexPath.section == Section.search.rawValue {
            return SearchTableViewCell.cellHeight
        }
        return 76
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == Section.segmented.rawValue {
            return 1
        }
        else if section == Section.banner.rawValue {
            return banners.count
        }
        else if section == Section.search.rawValue {
            return tableView.tag == SegmentedIndex.test.rawValue ? 1 : 0
        }
        if tableView.tag == 0 {
            return 20
        }
        else if tableView.tag == 1 {
            return 2
        }
        return 4 + tableView.tag * 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == Section.segmented.rawValue ||
            indexPath.section == Section.banner.rawValue {
            
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "emptyCell")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "emptyCell")
                cell.selectionStyle = .none
            }
            cell.backgroundColor = .clear
            
            return cell
        }
        else if indexPath.section == Section.search.rawValue && tableView.tag == SegmentedIndex.test.rawValue {
            var cell: SearchTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as? SearchTableViewCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed("SearchTableViewCell", owner: nil, options: nil)?.last as? SearchTableViewCell
            }
            
            cell.searchBlockTapped = { [weak self] in
                self?.searchTapped(cell)
            }
            
            return cell
        }
        var cell: HistoryTransactionCell! = tableView.dequeueReusableCell(withIdentifier: "HistoryTransactionCell") as? HistoryTransactionCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("HistoryTransactionCell", owner: nil, options: nil)?.last as? HistoryTransactionCell
        }

        cell.viewHistory.labelTitle.text = "table \(tableView.tag + 1), row \(indexPath.row + 1)"
        return cell
    }
}

extension ViewController: ContainerViewDelegate {
    func containerViewDidRemoveView(_ view: UIView) {
        banners.removeAll(where: {$0 == view})
        viewCustom.removeView(view, animation: true)
    }
}
