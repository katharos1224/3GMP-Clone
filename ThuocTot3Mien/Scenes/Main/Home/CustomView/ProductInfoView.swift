//
//  ProductInfoView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 18/12/2023.
//

import SDWebImage
import UIKit

class ProductInfoView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var tagStack: UIStackView!
    @IBOutlet var productView: UIView!
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("ProductInfoView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowRadius = 6.0
        contentView.layer.cornerRadius = 10.0

        discountView.layer.cornerRadius = discountView.frame.size.height / 2
        contentView.invalidateIntrinsicContentSize()
    }

    func configure(productData: CartProduct) {
        discountPriceLabel.isHidden = productData.khuyenMai != nil ? false : true
        discountView.isHidden = productData.khuyenMai != nil ? false : true
        bonusCoinsLabel.isHidden = productData.bonusCoins != 0 ? false : true

        if let tags = productData.tags, !tags.isEmpty {
            tags.forEach { tag in
                let tagView = TagView()
                tagView.configure(name: tag.name)
                tagStack.addArrangedSubview(tagView)
                tagView.contentView.layer.cornerRadius = tagView.frame.size.height / 2
            }
        }

        bonusCoinsLabel.text = "Tặng \(String(describing: productData.bonusCoins)) Coins"
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

        if let minAmount = productData.soLuongToiThieu {
            minAmountLabel.text = "Số lượng tối thiểu: \(minAmount)"
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

        contentView.invalidateIntrinsicContentSize()
    }

    func configure(productData: OrderedProductItem) {
        discountPriceLabel.isHidden = productData.khuyenMai != nil ? false : true
        discountView.isHidden = productData.khuyenMai != nil ? false : true
        bonusCoinsLabel.isHidden = productData.bonusCoins != nil && productData.bonusCoins != 0 ? false : true
        minAmountLabel.isHidden = true
        maxAmountLabel.isHidden = true
        packingLabel.isHidden = true

        if let tags = productData.tags, !tags.isEmpty {
            tags.forEach { tag in
                let tagView = TagView()
                tagView.configure(name: tag.name)
                tagStack.addArrangedSubview(tagView)
                tagView.contentView.layer.cornerRadius = tagView.frame.size.height / 2
            }
        }

        if let bonusCoins = productData.bonusCoins {
            bonusCoinsLabel.text = "Tặng \(String(describing: bonusCoins)) Coins"
        }
        discountLabel.text = "-\(String(describing: productData.khuyenMai ?? 0))%"
        productNameLabel.text = productData.tenSanPham
        discountPriceLabel.text = "\(Int(round(productData.discountPrice)).formattedWithSeparator()) VNĐ"

        let unitPriceText = "\(Int(productData.donGia).formattedWithSeparator()) VNĐ"
        if productData.khuyenMai != nil {
            unitPriceLabel.attributedText = unitPriceText.strikethrough()
            unitPriceLabel.textColor = .label
        } else {
            unitPriceLabel.attributedText = unitPriceText.strikethrough(useStrikethrough: false)
            unitPriceLabel.textColor = .systemGreen
        }

        productImage.sd_setImage(with: URL(string: productData.imgUrl ?? ""), placeholderImage: UIImage(systemName: "photo"))

        contentView.invalidateIntrinsicContentSize()
    }
}
