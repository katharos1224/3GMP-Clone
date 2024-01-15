//
//  ProductsVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 07/12/2023.
//

import UIKit

final class ProductsVC: BaseViewController {
    @IBOutlet var bannerView: BannerView!
    @IBOutlet var collectionView: UICollectionView!

    var titleLabel: String = ""
    var categoryProducts: [CategoryProduct] = []
    var memberStatus: Int = 0

    var search: String?
    var currentPage: Int = 1
    var lastPage: Int?
    var isLoadingMore = false
    var section: Int?
    var id: Int = 0
    var category: String?

    let cellWidth = (1 / 2) * UIScreen.main.bounds.width - 24
    let cellHeight = (2 / 5) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 16.0

    let bannerWidth = UIScreen.main.bounds.width - 32
    let bannerHeight = (264 / 651) * (UIScreen.main.bounds.width - 32)

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
        bannerView.configure(title: titleLabel)
        bannerView.dismiss = {
            self.popWithCrossDissolve()
        }

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(ProductCVCell.self, nibName: ProductCVCell.identifier)

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.hideLoadingIndicator()
        }
//        setupData()
    }

//    func setupData() {
//        NetworkManager.shared.fetchProducts(page: 1, category: category, search: nil, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil, hastag: nil) { [weak self] result in
//            switch result {
//            case let .success(data):
//                guard let response = data.response else {
//                    return
//                }
//                self?.categoryProducts = response.data
//                self?.lastPage = response.lastPage
//                DispatchQueue.main.async {
//                    self?.collectionView.reloadData()
//                    self?.hideLoadingIndicator()
//                }
//            case let .failure(error):
//                print(error.localizedDescription)
//            }
//        }
//    }

    override func viewWillAppear(_: Bool) {
        bannerView.textField.text = search
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    @IBAction func backAction(_: Any) {
        popWithCrossDissolve()
    }
}

extension ProductsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return categoryProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCVCell.identifier, for: indexPath) as! ProductCVCell

        cell.configure(categoryProductData: categoryProducts[indexPath.item], memberStatus: memberStatus)

        cell.addCartButton.backgroundColor = memberStatus == 2 ? .systemGreen : .placeholderText
        cell.addCartButton.isUserInteractionEnabled = memberStatus == 2 ? true : false

        if cell.addCartButton.isUserInteractionEnabled {
            cell.addToCartOnClick = { [self] in
                print("Added to cart!")
            }
        }

        cell.cellTapOnClick = { [self] in
            print("Cell got tap!!!!!!")
        }

        return cell
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if let lastPage = lastPage, offsetY > contentHeight - height {
            if !isLoadingMore, currentPage < lastPage {
                loadMoreData()
            }
        }
    }

    func loadMoreData() {
        isLoadingMore = true
        currentPage += 1

        NetworkManager.shared.fetchProducts(page: currentPage, category: category != nil ? category : nil, search: search != nil ? search : nil, hoatChat: section == 0 ? id : nil, nhomThuoc: section == 1 ? id : nil, nhaSanXuat: section == 2 ? id : nil, hastag: nil) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    self?.isLoadingMore = false
                    return
                }

                self?.categoryProducts += response.data

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.isLoadingMore = false
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
