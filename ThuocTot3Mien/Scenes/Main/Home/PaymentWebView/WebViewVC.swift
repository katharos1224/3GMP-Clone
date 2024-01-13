//
//  WebViewVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import UIKit
import WebKit

final class WebViewVC: BaseViewController {
    @IBOutlet var paymentWebView: WKWebView!
    @IBOutlet var titleName: UILabel!

    var targetURL: URL?
    var navTitle: String = "Tin tức"

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(url: URL) {
        self.init()
        targetURL = url
    }

    override func viewDidLoad() {
//        super.viewDidLoad()

        if let url = targetURL {
            loadWebView(with: url)
        }

        let backButton = UIBarButtonItem(title: "Trở về", style: .plain, target: self, action: #selector(dismissWebViewVC))
        navigationItem.leftBarButtonItem = backButton

//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            self.popToRoot()
//        }

        titleName.text = navTitle
    }

    func loadWebView(with url: URL) {
        let request = URLRequest(url: url)
        paymentWebView.load(request)
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
        }
    }

    @objc func dismissWebViewVC() {
        popWithCrossDissolve()
    }

    @IBAction func dismissTapped() {
        popWithCrossDissolve()
    }
}

extension WebViewVC: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        showLoadingIndicator()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        hideLoadingIndicator()
    }
}
