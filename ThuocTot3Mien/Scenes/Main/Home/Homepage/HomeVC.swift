//
//  HomeVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import FFPopup
import SDWebImage
import UIKit

final class HomeVC: BaseViewController {
    @IBOutlet var cartAmountContainerView: UIView!
    @IBOutlet var cartAmountLabel: UILabel!
    @IBOutlet var bannerView: UIView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var verifyLabel: UILabel!
    @IBOutlet var verifyImage: UIImageView!
    @IBOutlet var cartImage: UIImageView!
    @IBOutlet var bannerCollectionView: UICollectionView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    let addCartContentView: AddCartPopupView = {
        let width = UIScreen.main.bounds.size.width
        let height = width * 4 / 5
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = AddCartPopupView(frame: frame)
        return view
    }()

    let successfullyContentView: AddCartSuccessfullyPopupView = {
        let width = UIScreen.main.bounds.size.width
        let height = width * 1 / 7
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = AddCartSuccessfullyPopupView(frame: frame)
        return view
    }()

    var addCartPopupView = FFPopup()
    var successfullyPopupView = FFPopup()

    let cellWidth = (1 / 2) * UIScreen.main.bounds.width - 24
    let cellHeight = (2 / 5) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 16.0
    let bannerWidth = UIScreen.main.bounds.width - 32
    let bannerHeight = (264 / 651) * (UIScreen.main.bounds.width - 32)

    var memberStatus: Int = 0
    var totalCart: Int = 0
    var productsData: [Product] = []
    var bannerData: [Banner] = []
    var addedProducts: [ProductData] = []

    var onEndEditing: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 251 / 255, green: 251 / 255, blue: 204 / 255, alpha: 1.0)

        NetworkManager.shared.fetchHomepage { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                self?.productsData = response.products
                self?.bannerData = response.banners
                self?.memberStatus = response.memberStatus
                self?.totalCart = response.totalCart

                DispatchQueue.main.async {
                    self?.verifyImage.sd_setImage(with: URL(string: response.iconRank))
                    self?.verifyLabel.isHidden = response.memberStatus == 2 ? true : false
                    self?.usernameLabel.text = "\(response.memberName)"
                    self?.cartAmountLabel.text = "\(response.totalCart)"
                    self?.cartAmountContainerView.isHidden = response.totalCart > 0 ? false : true

                    self?.bannerCollectionView.isHidden = response.banners.isEmpty ? true : false
                    self?.bannerCollectionView.reloadData()
                    self?.reloadDataAndAdjustHeight()
                    self?.hideLoadingIndicator()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        showLoadingIndicator()

        NetworkManager.shared.fetchHomepage { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                self?.totalCart = response.totalCart

                DispatchQueue.main.async {
                    self?.usernameLabel.text = response.memberName
                    self?.cartAmountLabel.text = "\(response.totalCart)"
                    self?.cartAmountContainerView.isHidden = response.totalCart > 0 ? false : true
                    self?.hideLoadingIndicator()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cartAmountContainerView.layer.cornerRadius = cartAmountContainerView.frame.size.height / 2
    }

    override func setupUI() {
        super.setupUI()

        navigationController?.setNavigationBarHidden(true, animated: false)

        let searchTap = UITapGestureRecognizer(target: self, action: #selector(searchTapped))
        searchView.addGestureRecognizer(searchTap)

        setupCollectionView()
    }

    func setupCollectionView() {
        let layout = PagingCollectionViewLayout()
        let bannerLayout = PagingCollectionViewLayout()

        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical

        bannerLayout.sectionInset = .init(top: 0.0, left: padding, bottom: 0.0, right: padding)
        bannerLayout.itemSize = .init(width: bannerWidth, height: bannerHeight)
        bannerLayout.minimumLineSpacing = spacing * 2
        bannerLayout.minimumInteritemSpacing = spacing
        bannerLayout.scrollDirection = .horizontal

        collectionView.collectionViewLayout = layout
        bannerCollectionView.collectionViewLayout = bannerLayout

        collectionView.registerHeaderFromNib(HomepageHeaderCRView.self, nibName: HomepageHeaderCRView.identifier)
        collectionView.registerCellFromNib(ProductCVCell.self, nibName: ProductCVCell.identifier)
        bannerCollectionView.registerCellFromNib(OnboardingCVCell.self, nibName: OnboardingCVCell.identifier)

        collectionView.backgroundColor = .white
        bannerCollectionView.backgroundColor = .white

        startAutoScroll(for: bannerCollectionView, with: 2.0)
    }

    @objc private func searchTapped() {
        let vc = SearchResultVC()
        pushWithCrossDissolve(vc)
    }

    func reloadDataAndAdjustHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        heightConstraint.constant = contentHeight
    }

    @IBAction func goToCartTapped() {
        let vc = CartVC()
        pushWithCrossDissolve(vc)
    }

    func showAddCartPopup() {
        addCartPopupView = FFPopup(contentView: addCartContentView, showType: .slideInFromBottom, dismissType: .slideOutToBottom, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        let layout = FFPopupLayout(horizontal: .center, vertical: .bottom)
        addCartPopupView.show(layout: layout)
    }

    func showSuccessfullyPopup() {
        successfullyPopupView = FFPopup(contentView: successfullyContentView, showType: .slideInFromBottom, dismissType: .slideOutToBottom, maskType: .clear, dismissOnBackgroundTouch: true, dismissOnContentTouch: true)
        let layout = FFPopupLayout(horizontal: .center, vertical: .bottom)
        successfullyPopupView.show(layout: layout)
    }

    func dismissPopup(popupView: FFPopup) {
        popupView.dismiss(animated: true)
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case bannerCollectionView:
            return 1
        default:
            return productsData.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case bannerCollectionView:
            return bannerData.count
        default:
//            productsData[section].data = productsData[section].data.filter { $0.soLuong != 0 }
//            let itemsCount = productsData[section].data.filter { $0.soLuong != 0 }.count
            let itemsCount = productsData[section].data.count

            switch section {
            case productsData.count - 1:
                return itemsCount
            default:
                if itemsCount >= 4 {
                    return 4
                } else {
                    return itemsCount
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case bannerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCVCell.identifier, for: indexPath) as! OnboardingCVCell
            cell.configureBanner(imgURL: bannerData[indexPath.item].value)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCVCell.identifier, for: indexPath) as! ProductCVCell

            let product = productsData[indexPath.section].data[indexPath.item]
            let totalAmount = product.soLuong

            cell.configure(productData: product, memberStatus: memberStatus)

            let view = addCartContentView
            view.amountField.delegate = self

            if cell.addCartButton.isUserInteractionEnabled {
                cell.addToCartOnClick = { [self] in
                    showAddCartPopup()

                    view.configure(productData: product)

                    onEndEditing = { [self] in
                        if let text = view.amountField.text, let amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu {
                                if amount < minAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                    view.amountField.text = "\(minAmount)"
                                }
                            }

                            if let maxAmount = product.soLuongToiDa {
                                if amount > maxAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                    view.amountField.text = "\(maxAmount)"
                                }
                            }

                            if amount > totalAmount {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Vượt quá số lượng sản phẩm: \(totalAmount)")
                                view.amountField.text = "\(totalAmount)"
                            } else if amount < 1 {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0")
                                view.amountField.text = "\(1)"
                            }
                        }
                    }

                    if let minAmount = product.soLuongToiThieu {
                        view.amountField.text = "\(minAmount)"
                    } else {
                        view.amountField.text = "\(1)"
                    }

                    view.minusOnClick = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu {
                                if amount - minAmount > 0 {
                                    amount -= 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                    view.amountField.text = "\(minAmount)"
                                }
                            } else {
                                if amount > 1 {
                                    amount -= 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0.")
                                    view.amountField.text = "\(1)"
                                }
                            }
                        }
                    }

                    view.plusOnClick = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let maxAmount = product.soLuongToiDa {
                                if maxAmount - amount > 0 {
                                    amount += 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                    view.amountField.text = "\(maxAmount)"
                                }
                            } else {
                                if totalAmount - amount > 0 {
                                    amount += 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Vượt quá số lượng sản phẩm: \(totalAmount)")
                                    view.amountField.text = "\(totalAmount)"
                                }
                            }
                        }
                    }

                    view.addCartOnClick = { [self] in
                        if let text = view.amountField.text, let amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu {
                                if amount < minAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                    view.amountField.text = "\(minAmount)"
                                }
                            }

                            if let maxAmount = product.soLuongToiDa {
                                if amount > maxAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                    view.amountField.text = "\(maxAmount)"
                                }
                            }

                            if amount > totalAmount {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Vượt quá số lượng sản phẩm: \(totalAmount)")
                                view.amountField.text = "\(totalAmount)"
                            } else if amount < 1 {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0")
                                view.amountField.text = "\(1)"
                            } else {
                                let id = product.id
                                let number = amount

                                NetworkManager.shared.updateCart(id: id, number: number) { [weak self] result in
                                    switch result {
                                    case let .success(data):
                                        guard let response = data.response else { return }
                                        if let addCartPopupView = self?.addCartPopupView {
                                            self?.dismissPopup(popupView: addCartPopupView)
                                        }

                                        DispatchQueue.main.async {
                                            self?.showSuccessfullyPopup()
                                            self?.cartAmountLabel.text = "\(String(describing: response.totalNumber))"
                                            self?.cartAmountContainerView.isHidden = response.totalNumber > 0 ? false : true
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            if let successfullyPopupView = self?.successfullyPopupView {
                                                self?.dismissPopup(popupView: successfullyPopupView)
                                            }
                                        }
                                    case let .failure(error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            cell.cellTapOnClick = {
                print("Product: \(product.tenSanPham) \nSo luong: \(product.soLuong)")
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == self.collectionView {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomepageHeaderCRView.identifier, for: indexPath) as! HomepageHeaderCRView

                headerView.configure(title: productsData[indexPath.section].name)

                headerView.onClick = { [weak self] in
                    let vc = ProductsVC()
                    vc.titleLabel = self?.productsData[indexPath.section].name ?? ""
                    vc.memberStatus = self?.memberStatus ?? 0

                    let category = self?.productsData[indexPath.section].value
                    vc.category = category

                    DispatchQueue.main.async {
                        self?.pushWithCrossDissolve(vc)
                    }
                }

                return headerView
            }
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.width, height: 70.0)
        } else {
            return CGSize()
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_: UITextField) {
        onEndEditing?()
        view.endEditing(true)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        onEndEditing?()
        view.endEditing(true)
        return true
    }
}
