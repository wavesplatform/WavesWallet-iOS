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
    func browserViewRedirect(_ browserViewController: BrowserViewController, url: URL)
    func browserViewDismissed(_ browserViewController: BrowserViewController)
}

extension BrowserViewControllerDelegate {
    func browserViewRedirect(_: BrowserViewController, url _: URL) {}
    func browserViewDismissed(_: BrowserViewController) {}
}

final class BrowserViewController: UIViewController {
    private let url: URL

    private var webView: WKWebView!
    private var loader: UIActivityIndicatorView!

    var delegate: BrowserViewControllerDelegate?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
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

    @objc func done(sender _: Any) {
        delegate?.browserViewDismissed(self)
        dismiss(animated: true)
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        finishLoading()
    }

    func webView(_: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.navigationType == .other || navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                delegate?.browserViewRedirect(self, url: url)
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

    @discardableResult static func openURL(_ url: URL,
                                           toViewController: UIViewController,
                                           delegate: BrowserViewControllerDelegate? = nil) -> BrowserViewController {
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

        return vc
    }
}
