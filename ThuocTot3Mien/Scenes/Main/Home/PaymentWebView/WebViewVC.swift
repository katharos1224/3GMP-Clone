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
    @IBOutlet weak var titleName: UILabel!
    
    
    var targetURL: URL?
    var navTitle: String?

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
        
        if let title = navTitle {
            titleName.text = title
        }
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
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoadingIndicator()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingIndicator()
    }
}
