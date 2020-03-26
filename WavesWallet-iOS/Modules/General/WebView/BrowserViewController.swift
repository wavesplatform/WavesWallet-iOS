//
//  WebViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 13/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import WebKit

protocol BrowserViewControllerDelegate: AnyObject {
    
    func browserViewRedirect(url: URL)
    func browserViewDissmiss()
}

extension BrowserViewControllerDelegate {
    func browserViewRedirect(url: URL) {}
    func browserViewDissmiss() {}
}


final class BrowserViewController: UIViewController {
    
    private let url: URL
    
    private var webView: WKWebView!
    private var loader: UIActivityIndicatorView!
    
    var delegate: BrowserViewControllerDelegate? = nil
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(done(sender:)))
        
        setupWebView()
        setupLoader()
        
        let myURL = url
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    private func setupWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
 
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func setupLoader() {
        loader = UIActivityIndicatorView(style: .gray)
        loader.hidesWhenStopped = true
        loader.startAnimating()
        view.addSubview(loader)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let y: CGFloat = (navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height
        
        webView.frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height - y)
        
        let safeInsets = webView.scrollView.adjustedContentInsetAdapter
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: safeInsets.bottom, right: 0)

        loader.center = view.center
    }
    
    // MARK: - Content
    
    fileprivate func finishLoading() {
        loader.stopAnimating()
    }
    
    @objc func done(sender: Any) {
        self.delegate?.browserViewDissmiss()
        dismiss(animated: true)
    }
}

extension BrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishLoading()
    }
    
    func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        if(navigationAction.navigationType == .other) {
            if navigationAction.request.url != nil {
                self.delegate?.browserViewRedirect(url: url)
            }
            decisionHandler(.allow)
            return
        }
        decisionHandler(.allow)
    }
}

extension BrowserViewController {
    static func openURL(_ url: URL, delegate: BrowserViewControllerDelegate? = nil) {
        if let vc = AppDelegate.shared().window?.rootViewController {
            openURL(url, toViewController: vc, delegate: delegate)
        }
    }
    
    static func openURL(_ url: URL,
                        toViewController: UIViewController,
                        delegate: BrowserViewControllerDelegate? = nil) {
        let vc = BrowserViewController(url: url)
        vc.delegate = delegate
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        let newToViewController: UIViewController = {
               
               if toViewController.presentedViewController != nil {
                   return toViewController.presentedViewController ?? toViewController
               } else {
                   return toViewController
               }
         }()
                
        newToViewController.present(nav, animated: true, completion: nil)
    }
}
