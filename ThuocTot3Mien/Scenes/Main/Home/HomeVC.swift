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

    let cellWidth = (1 / 2) * Constants.WIDTH_SCREEN - 24
    let cellHeight = (9 / 10) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING
    let bannerWidth = Constants.WIDTH_SCREEN - 32
    let bannerHeight = (264 / 651) * (Constants.WIDTH_SCREEN - 32)

    var memberStatus: Int = 0
    var totalCart: Int = 0
    var productsData: [Product] = []
    var bannerData: [Banner] = []
    var addedProducts: [ProductData] = []

    var onEndEditing: (() -> Void)?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.COLOR_BACKGROUND
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addCartPopupView.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        addCartPopupView.frame.origin.y = 0
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
