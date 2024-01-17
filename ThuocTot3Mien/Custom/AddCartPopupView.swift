//
//  AddCartPopupView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/12/2023.
//

import Foundation
import UIKit
import IQKeyboardManager

class AddCartPopupView: UIView, UITextFieldDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet var discountView: UIView!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var discountLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var bonusCoinsLabel: UILabel!
    @IBOutlet var packingLabel: UILabel!
    @IBOutlet var discountPriceLabel: UILabel!
    @IBOutlet var unitPriceLabel: UILabel!
    @IBOutlet var minAmountLabel: UILabel!
    @IBOutlet var maxAmountLabel: UILabel!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var minusImage: UIImageView!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var addCartButton: UIButton!
    @IBOutlet weak var tagStack: UIStackView!
    

    var minusOnClick: (() -> Void)?
    var plusOnClick: (() -> Void)?
    var addCartOnClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("AddCartPopupView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)

        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer

        let minusTap = UITapGestureRecognizer(target: self, action: #selector(minusTapped))
        let plusTap = UITapGestureRecognizer(target: self, action: #selector(plusTapped))
        minusImage.addGestureRecognizer(minusTap)
        plusImage.addGestureRecognizer(plusTap)
        amountField.delegate = self
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        discountView.layer.masksToBounds = true
        discountView.layer.cornerRadius = discountView.bounds.size.height / 2
        addCartButton.layer.cornerRadius = addCartButton.bounds.size.height / 2
        layoutIfNeeded()
    }

    @objc private func minusTapped() {
        minusOnClick?()
    }

    @objc private func plusTapped() {
        plusOnClick?()
    }

    func configure(productData: ProductData) {
//        if !productData.tags.isEmpty {
//            tagStack.isHidden = false
//            productData.tags.forEach { tag in
//                let tagView = TagView()
//                tagView.configure(name: tag.name)
//                tagView.layer.cornerRadius = tagView.frame.size.height / 2
//                tagStack.addArrangedSubview(tagView)
//            }
//        } else {
//            tagStack.isHidden = false
//        }
        
        discountPriceLabel.isHidden = productData.khuyenMai != nil ? false : true
        discountView.isHidden = productData.khuyenMai != nil ? false : true
        bonusCoinsLabel.isHidden = productData.bonusCoins != nil && productData.bonusCoins != 0 ? false : true

        bonusCoinsLabel.text = "Tặng \(String(describing: productData.bonusCoins ?? 0)) Coins"
        discountLabel.text = "-\(String(describing: Int(round(productData.khuyenMai ?? 0))))%"
        productNameLabel.text = productData.tenSanPham
        packingLabel.text = productData.quyCachDongGoi
        discountPriceLabel.text = "\(Int(round(productData.discountPrice)).formattedWithSeparator()) VNĐ"

        let unitPriceText = "\(Int(productData.donGia).formattedWithSeparator()) VNĐ"
        if productData.khuyenMai != nil {
            unitPriceLabel.attributedText = unitPriceText.strikethrough()
            unitPriceLabel.textColor = .label
        } else {
            unitPriceLabel.attributedText = unitPriceText.strikethrough(useStrikethrough: false)
            unitPriceLabel.textColor = .systemGreen
        }

        amountField.text = "\(1)"

        if let minAmount = productData.soLuongToiThieu {
            minAmountLabel.text = "Số lượng tối thiểu: \(minAmount)"
            amountField.text = "\(minAmount)"
            minAmountLabel.isHidden = false
        } else {
            minAmountLabel.isHidden = true
        }

        if let maxAmount = productData.soLuongToiDa {
            maxAmountLabel.text = "Số lượng tối đa: \(maxAmount)"
            maxAmountLabel.isHidden = false
        } else {
            maxAmountLabel.isHidden = true
        }

        productImage.sd_setImage(with: URL(string: productData.imgUrl ?? ""), placeholderImage: UIImage(systemName: "photo"))
    }

    @IBAction func addCartTapped() {
        addCartOnClick?()
    }
}
