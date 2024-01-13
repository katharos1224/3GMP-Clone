//
//  PaymentDetailVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 03/01/2024.
//

import UIKit

final class PaymentDetailVC: BaseViewController {
    var dimmingView: UIView?

    @IBOutlet var detailView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var navBarView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var generalView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var totalNumber: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBOutlet var paymentIdLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var voucherLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var coinBonusLabel: UILabel!
    @IBOutlet var noteLabel: UILabel!

    @IBOutlet var useCoinStatus: UILabel!
    @IBOutlet var useVoucherStatus: UILabel!
    @IBOutlet var bonusCoinStatus: UILabel!
    @IBOutlet var noteStatus: UILabel!

    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!

    private var isBottomViewShown: Bool = false

    var orderedProducts: [OrderedProductItem] = []
    var paymentID: Int = 0
    var currentPage: Int = 0

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
        setupData()
    }

    override func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        titleLabel.text = "Chi tiết đơn hàng \(paymentID)"

        let cellWidth = UIScreen.main.bounds.width
        let cellHeight = (1 / 5) * UIScreen.main.bounds.height
        let spacing = 0.0
        let padding = 0.0

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.registerCellFromNib(PurchaseCVCell.self, nibName: PurchaseCVCell.identifier)

        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: UIScreen.main.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        generalView.layer.mask = maskLayer

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        heightConstraint.constant = 0
        contentHeightConstraint.constant = 0
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: detailView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        detailView.layer.mask = maskLayer
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !detailView.frame.contains(location) && isBottomViewShown {
            hideBottomView()
        }
    }

    private func setupData() {
        NetworkManager.shared.fetchOrderDetail(id: paymentID, page: currentPage) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    return
                }
                self?.orderedProducts = response.products.data

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.totalNumber.text = "\(response.totalProducts)"
                    self?.totalPrice.text = "\(response.totalPrice.formattedWithSeparator()) VND"

                    self?.paymentIdLabel.text = "\(self?.paymentID ?? 0)"
                    self?.dateLabel.text = "\(response.dateTime)"
                    self?.totalPriceLabel.text = "\(response.totalPrice.formattedWithSeparator()) VND"
                    self?.priceLabel.text = "\(response.price.formattedWithSeparator()) VND"
                    self?.totalPriceLabel.text = "\(response.price.formattedWithSeparator()) VND"

                    if let coin = response.coinValue, coin != 0 {
                        self?.coinLabel.text = "-\(coin.formattedWithSeparator()) VND"
                        self?.useCoinStatus.text = "Sử dụng \(coin.formattedWithSeparator()) Coin"
                        self?.coinLabel.isHidden = false
                        self?.useCoinStatus.isHidden = false
                    } else {
                        self?.coinLabel.isHidden = true
                        self?.useCoinStatus.isHidden = true
                    }

                    if let voucher = response.voucher, voucher != "", let voucherValue = response.voucherValue, voucherValue != 0 {
                        self?.voucherLabel.text = "-\(voucherValue.formattedWithSeparator()) VND"
                        self?.useVoucherStatus.text = "Sử dụng voucher (\(voucher))"
                        self?.voucherLabel.isHidden = false
                        self?.useVoucherStatus.isHidden = false
                    } else {
                        self?.voucherLabel.isHidden = true
                        self?.useVoucherStatus.isHidden = true
                    }

                    if let bonusCoin = response.coinBonus, bonusCoin != 0 {
                        self?.coinBonusLabel.text = "+\(bonusCoin) Coin"
                        self?.coinBonusLabel.isHidden = false
                        self?.bonusCoinStatus.isHidden = false
                    } else {
                        self?.coinBonusLabel.isHidden = true
                        self?.bonusCoinStatus.isHidden = true
                    }

                    if let note = response.ghiChu {
                        self?.noteLabel.text = "\(note)"
                        self?.noteLabel.isHidden = false
                        self?.noteStatus.isHidden = false
                    } else {
                        self?.noteLabel.isHidden = true
                        self?.noteStatus.isHidden = true
                    }
                }

            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    private func updateBottomViewHeight() {
        view.layoutIfNeeded()
    }

    private func addDimmingView() {
        dimmingView = UIView(frame: view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView?.alpha = 0
        view.addSubview(dimmingView!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView?.addGestureRecognizer(tapGesture)

        UIView.animate(withDuration: 0.3) {
            self.dimmingView?.alpha = 1
        }
    }

    private func removeDimmingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmingView?.alpha = 0
        }) { _ in
            self.dimmingView?.removeFromSuperview()
            self.dimmingView = nil
        }
    }

    private func showBottomView() {
        addDimmingView()

        view.addSubview(detailView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.heightConstraint.constant = UIScreen.main.bounds.height * 3 / 10
            self.updateBottomViewHeight()
            self.view.layoutIfNeeded()
        }
        isBottomViewShown = true
    }

    private func hideBottomView() {
        let animation = CABasicAnimation(keyPath: "bounds.size.height")
        animation.fromValue = detailView.bounds.size.height
        animation.toValue = 0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        detailView.layer.add(animation, forKey: "bounds.size.height")

        DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration) {
            self.heightConstraint.constant = 0
            self.contentHeightConstraint.constant = 0
            self.updateBottomViewHeight()
            self.removeDimmingView()
        }
        isBottomViewShown = false
    }

    @IBAction func backButtonTapped() {
        popWithCrossDissolve()
    }

    @IBAction func showPaymentDetailPopup() {
        isBottomViewShown ? hideBottomView() : showBottomView()
    }
}

extension PaymentDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return orderedProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PurchaseCVCell.identifier, for: indexPath) as! PurchaseCVCell
        let product = orderedProducts[indexPath.item]

        cell.configure(productData: product)

        return cell
    }
}
