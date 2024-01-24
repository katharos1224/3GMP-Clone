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
    var navTitle: String?
    var isEditProduct: Bool = false
    var productID: String?

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
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        if isEditProduct {
            if let id = productID {
                loadWebViewWithToken(with: id)
            }
        } else {
            if let url = targetURL {
                loadWebView(with: url)
            }
        }

        let backButton = UIBarButtonItem(title: "Trở về", style: .plain, target: self, action: #selector(dismissWebViewVC))
        navigationItem.leftBarButtonItem = backButton

        titleName.text = navTitle
    }

    func loadWebView(with url: URL) {
        let request = URLRequest(url: url)
        paymentWebView.load(request)
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
        }
    }
    
    func loadWebViewWithToken(with id: String) {
        let urlString = "http://18.138.176.213/agency/products/edit/\(id)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        
        guard let token = KeychainService.getToken() else {
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        paymentWebView.load(request)
        
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
        }
    }

    override func viewDidAppear(_: Bool) {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
        }
    }

    @objc func dismissWebViewVC() {
        popWithCrossDissolve()
    }

    @IBAction func dismissTapped() {
        if let _ = navigationController {
            popToRoot()
        } else {
            hide()
        }
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
