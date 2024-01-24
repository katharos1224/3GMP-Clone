//
//  ProductsVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 07/12/2023.
//

import UIKit
import FFPopup

final class ProductsVC: BaseViewController {
    @IBOutlet var bannerView: BannerView!
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var heightConstraint: NSLayoutConstraint!

    var titleLabel: String = ""
    var categoryProducts: [CategoryProduct] = []
    var agencyProducts: [AgencyProduct] = []
    var memberStatus: Int = 0
    var totalNumber: Int = 0

    var search: String?
    var currentPage: Int = 1
    var lastPage: Int?
    var isLoadingMore = false
    var section: Int?
    var id: Int = 0
    var category: String?

    let cellWidth = (1 / 2) * Constants.WIDTH_SCREEN - 24
    var cellHeight = (9 / 10) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING

    let bannerWidth = Constants.WIDTH_SCREEN - 32
    let bannerHeight = (264 / 651) * (Constants.WIDTH_SCREEN - 32)
    
    let EditProductContentView: EditProductView = {
        let width = (17 / 20) * Constants.WIDTH_SCREEN
        let height = width * (9 / 20)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = EditProductView(frame: frame)
        return view
    }()

    var editProductViewPopupView = FFPopup()

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
        bannerView.cartButton.isHidden = false

        bannerView.configure(title: titleLabel)

        bannerView.dismiss = {
            self.popWithCrossDissolve()
        }

        bannerView.goToCartOnClick = {
            let vc = CartVC()
            if let _ = self.navigationController {
                self.pushWithCrossDissolve(vc)
            } else {
                self.show(vc)
            }
        }
        
        if !agencyProducts.isEmpty {
            bannerView.stackBar.isHidden = true
            bannerView.titleLabel.isHidden = false
            bannerView.titleLabel.text = titleLabel
        }

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(ProductCVCell.self, nibName: ProductCVCell.identifier)
        collectionView.backgroundColor = .white

        DispatchQueue.main.async {
            self.reloadDataAndAdjustHeight()
            self.hideLoadingIndicator()
        }
    }

    override func viewWillAppear(_: Bool) {
        bannerView.textField.text = search
        bannerView.totalNumber.text = "\(totalNumber)"
        bannerView.totalCartView.isHidden = totalNumber > 0 ? false : true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        bannerView.totalCartView.layer.cornerRadius = bannerView.totalCartView.frame.size.height / 2
    }

    func reloadDataAndAdjustHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        heightConstraint.constant = contentHeight
    }
    
    func showEditPopup() {
        editProductViewPopupView = FFPopup(contentView: EditProductContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: true)

        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        editProductViewPopupView.show(layout: layout)
    }

    func dismissPopup() {
        editProductViewPopupView.dismiss(animated: true)
    }

    @IBAction func backAction(_: Any) {
        popWithCrossDissolve()
    }
}

extension ProductsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return agencyProducts.isEmpty ? categoryProducts.count : agencyProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if agencyProducts.isEmpty {
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCVCell.identifier, for: indexPath) as! ProductCVCell
            
            cell.configure(agencyProductData: agencyProducts[indexPath.item], memberStatus: memberStatus)
            
            cell.hideOnClick = { [self] in
                let view = EditProductContentView
                let buttonTitle = cell.isHiddenProduct ? "Hiện ở gian hàng" : "Ẩn khỏi gian hàng"
                
                view.agreeButton.setTitle(buttonTitle, for: .normal)
                view.productName.text = agencyProducts[indexPath.item].tenSanPham
                
                view.agreeOnClick = { [self] in
//                    cell.isHiddenProduct.toggle()
                    
                    NetworkManager.shared.showProduct(id: agencyProducts[indexPath.item].id) { [weak self] result in
                        switch result {
                        case .success(let data):
                            guard data.response != nil else {
                                print(data.message)
                                return
                            }
                            
                            cell.isHiddenProduct.toggle()
                            
                            DispatchQueue.main.async {
                                cell.hideButton.tintColor = !cell.isHiddenProduct ? .systemGreen : .systemGray
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
                DispatchQueue.main.async { [self] in
                    showEditPopup()
                }
            }
            
            cell.bestSellerOnClick = { [self] in
                let view = EditProductContentView
                let buttonTitle = cell.isBestSeller ? "Xoá bán chạy" : "Thêm bán chạy"
                
                view.agreeButton.setTitle(buttonTitle, for: .normal)
                view.productName.text = agencyProducts[indexPath.item].tenSanPham
                
                view.agreeOnClick = { [self] in
                    NetworkManager.shared.pinBestSeller(id: agencyProducts[indexPath.item].id) { [weak self] result in
                        switch result {
                        case .success(let data):
                            guard data.response != nil else {
                                print(data.message)
                                return
                            }
                            
                            cell.isBestSeller.toggle()
                            
                            DispatchQueue.main.async {
                                cell.bestSellerButton.tintColor = cell.isBestSeller ? .systemGreen : .systemGray
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
                DispatchQueue.main.async { [self] in
                    showEditPopup()
                }
            }
            
            cell.editOnClick = {
                let vc = WebViewVC()
                let id = "\(self.agencyProducts[indexPath.item].id)"
                vc.isEditProduct = true
                vc.productID = id
                vc.navTitle = "Chỉnh sửa sản phẩm"
                
                DispatchQueue.main.async {
                    self.show(vc)
                }
            }
            
            cell.deleteOnClick = {
                
            }

            return cell
        }
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
                    self?.reloadDataAndAdjustHeight()
                    self?.isLoadingMore = false
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
