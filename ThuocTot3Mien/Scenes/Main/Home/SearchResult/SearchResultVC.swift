//
//  SearchResultVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 25/12/2023.
//

import Combine
import UIKit

final class SearchResultVC: BaseViewController {
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var clearButton: UIImageView!

    var productsResult: [SearchData] = []
    var currentPage: Int = 1
    var lastPage: Int?
    var search: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func setupUI() {
        super.setupUI()
        hideLoadingIndicator()
        searchTextField.becomeFirstResponder()
        tableView.registerCellFromNib(SearchResultCell.self, nibName: SearchResultCell.identifier)
        tableView.backgroundColor = .white

        cancellable = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                if let searchText = self?.searchTextField.text, searchText.count >= 2 {
                    self?.performSearch(query: searchText)
                }
            }

        let clearTap = UITapGestureRecognizer(target: self, action: #selector(clearTextTapped))
        clearButton.addGestureRecognizer(clearTap)
    }

    @objc func clearTextTapped() {
        searchTextField.text = ""
        productsResult.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func performSearch(query: String? = nil) {
        NetworkManager.shared.fetchSearchResult(search: query) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }

                self?.productsResult = response

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cornerRadius: CGFloat = 33
        let path = UIBezierPath(
            roundedRect: searchView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        searchView.layer.mask = maskLayer
    }

    @IBAction func backTapped() {
        popWithCrossDissolve()
    }
}

extension SearchResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return productsResult.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
        let product = productsResult[indexPath.row]
        cell.configure(product: product)

        cell.cellTapOnClick = { [weak self] in
            let vc = ProductsVC()
            let search = product.tenSanPham

            NetworkManager.shared.fetchProducts(page: nil, category: nil, search: search, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil, hastag: nil) { result in
                switch result {
                case let .success(data):
                    guard let response = data.response else {
                        return
                    }
                    vc.categoryProducts = response.data
                    vc.search = search

                    DispatchQueue.main.async {
                        self?.pushWithCrossDissolve(vc)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 12
    }
}

extension SearchResultVC: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
    }
}
