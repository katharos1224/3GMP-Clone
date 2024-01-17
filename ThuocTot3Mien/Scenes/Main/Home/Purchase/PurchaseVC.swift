//
//  PurchaseVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 15/12/2023.
//

import FFPopup
import UIKit
import WebKit

final class PurchaseVC: BaseViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var totalNumberLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var confirmView: UIView!

    var purchaseProducts: [CartProduct] = []
    var vouchersData: [Voucher] = []
    var totalNumber: Int = 0
    var totalPrice: Int = 0
    var coins: Int = 0
    var reductionRate: String = ""
    var cartIDs: [Int] = []
    var url: URL?

    lazy var createPaymentContentView: PaymentView = {
        let width = UIScreen.main.bounds.size.width
        let height = width * 31 / 20
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = PaymentView(frame: frame)
        view.delegate = self
        return view
    }()

    var createPaymentPopupView = FFPopup()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let cellWidth = Constants.WIDTH_SCREEN
        let cellHeight = (5 / 12) * cellWidth
        let spacing = Constants.SPACING_ZERO
        let padding = Constants.PADDING_ZERO

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(PurchaseCVCell.self, nibName: PurchaseCVCell.identifier)

        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: UIScreen.main.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        confirmView.layer.mask = maskLayer
    }

    private func setupData() {
        purchaseProducts.forEach { product in
            totalNumber += product.soLuong
            totalPrice += product.discountPrice == 0 ? product.donGia * product.soLuong : Int(round(product.discountPrice)) * product.soLuong
            coins += product.bonusCoins
            cartIDs.append(product.gioHangId)
        }

        DispatchQueue.main.async { [self] in
            totalNumberLabel.text = String(totalNumber)
            totalPriceLabel.text = String(totalPrice.formattedWithSeparator()) + " VNĐ"
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            createPaymentPopupView.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        createPaymentPopupView.frame.origin.y = 0
    }

    @IBAction func dismiss() {
        popWithCrossDissolve()
    }

    @IBAction func confirmTapped() {
        showCreatePaymentPopup()
    }

    func showCreatePaymentPopup() {
        NetworkManager.shared.fetchVouchers(cartIDs: cartIDs) { [self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                vouchersData = response
                createPaymentContentView.vouchers = vouchersData
                createPaymentContentView.cartIDs = cartIDs
            case let .failure(error):
                print(error.localizedDescription)
            }
        }

        createPaymentContentView.totalNumber = totalNumber
        createPaymentContentView.totalPrice = totalPrice
        createPaymentContentView.totalNumberLabel.text = "\(totalNumber)"
        createPaymentContentView.totalPriceLabel.text = "\(totalPrice.formattedWithSeparator()) VNĐ"
        createPaymentContentView.reductionRateLabel.text = "-\(reductionRate)%"
        createPaymentContentView.reductionRate = Double(reductionRate)!
        createPaymentContentView.useVoucher = false
        createPaymentContentView.useCoinsSwitch.isOn = false
        createPaymentContentView.useOnlinePayment = false
        createPaymentContentView.useOnlineCheckmark.image = UIImage(systemName: "square")
        createPaymentContentView.useOnlineCheckmark.tintColor = .placeholderText

        createPaymentContentView.returnHomepageOnClick = { [weak self] in
            let alertController = UIAlertController(title: "Thông báo", message: "Đơn hàng đã được tạo.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                DispatchQueue.main.async {
                    self?.dismissPopup()
                    self?.popToRoot()
                }
            }
            alertController.addAction(okAction)
            self?.present(alertController, animated: true, completion: nil)
        }

        if coins > 0 {
            createPaymentContentView.givenCoinsLabel.text = "Đơn được tặng tổng \(coins) Coins"
            createPaymentContentView.givenCoinsLabel.isHidden = false
        } else {
            createPaymentContentView.givenCoinsLabel.isHidden = true
        }

        createPaymentPopupView = FFPopup(contentView: createPaymentContentView, showType: .slideInFromBottom, dismissType: .slideOutToBottom, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        let layout = FFPopupLayout(horizontal: .center, vertical: .bottom)
        DispatchQueue.main.async {
            self.createPaymentPopupView.show(layout: layout)
            self.createPaymentPopupView.layoutIfNeeded()
        }
    }

    func dismissPopup() {
        DispatchQueue.main.async { [self] in
            createPaymentPopupView.dismiss(animated: true)
        }
    }
}

extension PurchaseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return purchaseProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PurchaseCVCell.identifier, for: indexPath) as! PurchaseCVCell
        let product = purchaseProducts[indexPath.item]

        cell.configure(productData: product)

        return cell
    }
}

extension PurchaseVC: PaymentViewDelegate {
    func didTapCreatePayment(withURL url: URL) {
        DispatchQueue.main.async { [self] in
            let paymentWebView = WebViewVC(url: url)
            paymentWebView.navTitle = "Thanh toán"
            show(paymentWebView)
        }
    }
}
