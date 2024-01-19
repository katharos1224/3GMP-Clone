//
//  ProductCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 06/12/2023.
//

import SDWebImage
import UIKit

class ProductCVCell: UICollectionViewCell {
    @IBOutlet var tagStack: UIStackView!
    @IBOutlet var discountView: UIView!
    @IBOutlet var discountLabel: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var bonusCoinsLabel: UILabel!
    @IBOutlet var packingLabel: UILabel!
    @IBOutlet var discountPriceLabel: UILabel!
    @IBOutlet var unitPriceLabel: UILabel!
    @IBOutlet var minAmountLabel: UILabel!
    @IBOutlet var maxAmountLabel: UILabel!

    @IBOutlet var addCartButton: UIButton!

    static let identifier: String = "ProductCVCell"

    var addToCartOnClick: (() -> Void)?
    var cellTapOnClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowRadius = 6.0

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        discountView.layer.cornerRadius = discountView.frame.size.height / 2
        addCartButton.layer.cornerRadius = addCartButton.frame.size.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tagStack.removeAllArrangedSubviews()
    }

    @objc private func cellTapped() {
        cellTapOnClick?()
    }

    @IBAction func addToCardTapped(_: CustomButton) {
        addToCartOnClick?()
    }

    func configure(productData: ProductData, memberStatus: Int) {
        discountView.isHidden = productData.khuyenMai != nil ? false : true
        bonusCoinsLabel.isHidden = productData.bonusCoins != nil && productData.bonusCoins != 0 ? false : true

        if !productData.tags.isEmpty {
            tagStack.isHidden = false
            productData.tags.forEach { tag in
                let tagView = TagView()
                if tag.name != "#haha" {
                    tagView.configure(name: tag.name)
                    tagView.layer.cornerRadius = tagView.frame.size.height / 2
                    tagStack.addArrangedSubview(tagView)
                }
            }
        }

        bonusCoinsLabel.text = "Tặng \(String(describing: productData.bonusCoins ?? 0)) Coins"
        discountLabel.text = "-\(String(describing: Int(round(productData.khuyenMai ?? 0))))%"
        productNameLabel.text = productData.tenSanPham
        packingLabel.text = productData.quyCachDongGoi
        discountPriceLabel.text = "\(Int(round(productData.discountPrice)).formattedWithSeparator()) VNĐ"

        let unitPriceText = "\(productData.donGia.formattedWithSeparator()) VNĐ"

        unitPriceLabel.attributedText = productData.khuyenMai != nil ? unitPriceText.strikethrough() : unitPriceText.strikethrough(useStrikethrough: false)
//        unitPriceLabel.textColor = productData.khuyenMai != nil && memberStatus == 2 ? .label : .systemGreen
//        discountPriceLabel.isHidden = productData.khuyenMai != nil && memberStatus == 2 ? false : true
        unitPriceLabel.textColor = productData.khuyenMai != nil ? .black : .systemGreen
        discountPriceLabel.isHidden = productData.khuyenMai != nil ? false : true

        unitPriceLabel.isHidden = memberStatus == 1 ? true : false
        if productData.khuyenMai != nil {
            discountPriceLabel.isHidden = memberStatus == 1 ? true : false
        }

        if let minNumber = productData.soLuongToiThieu {
            minAmountLabel.isHidden = false
            minAmountLabel.text = "Số lượng tối thiểu: \(minNumber)"
        } else {
            minAmountLabel.isHidden = true
        }

        if let maxNumber = productData.soLuongToiDa {
            maxAmountLabel.isHidden = false
            maxAmountLabel.text = "Số lượng tối đa: \(maxNumber)"
        } else {
            maxAmountLabel.isHidden = true
        }

        productImage.sd_setImage(with: URL(string: productData.imgUrl ?? ""), placeholderImage: UIImage(systemName: "photo"))

        addCartButton.backgroundColor = memberStatus == 2 && productData.soLuong != 0 ? .systemGreen : .lightGray
        addCartButton.isUserInteractionEnabled = memberStatus == 2 && productData.soLuong != 0 ? true : false
        addCartButton.setTitle(productData.soLuong != 0 ? "Thêm giỏ hàng" : "Hết hàng", for: .normal)

        if productData.soLuongToiDa == 0 {
            addCartButton.setTitle("Hết hàng", for: .normal)
            addCartButton.isUserInteractionEnabled = false
            addCartButton.backgroundColor = .lightGray
        }

        layoutIfNeeded()
    }

    func configure(categoryProductData: CategoryProduct, memberStatus: Int) {
        discountView.isHidden = categoryProductData.khuyenMai != nil ? false : true
//        bonusCoinsLabel.isHidden = categoryProductData.bonusCoins != nil && categoryProductData.bonusCoins != 0 ? false : true
        bonusCoinsLabel.isHidden = true

        if !categoryProductData.tags.isEmpty {
            categoryProductData.tags.forEach { tag in
                let tagView = TagView()
                if tag.name != "#haha" {
                    tagView.configure(name: tag.name)
                    tagView.layer.cornerRadius = tagView.frame.size.height / 2
                    tagStack.addArrangedSubview(tagView)
                }
            }
        }

//        bonusCoinsLabel.text = "Tặng \(String(describing: categoryProductData.bonusCoins ?? 0)) Coins"
        discountLabel.text = "-\(String(describing: Int(round(categoryProductData.khuyenMai ?? 0))))%"
        productNameLabel.text = categoryProductData.tenSanPham
        packingLabel.text = categoryProductData.quyCachDongGoi
        discountPriceLabel.text = "\(Int(round(categoryProductData.discountPrice))) VNĐ"

        let unitPriceText = "\(Int(categoryProductData.donGia)) VNĐ"

        unitPriceLabel.attributedText = categoryProductData.khuyenMai != nil ? unitPriceText.strikethrough() : unitPriceText.strikethrough(useStrikethrough: false)
//        unitPriceLabel.textColor = categoryProductData.khuyenMai != nil && memberStatus == 2 ? .label : .systemGreen
//        discountPriceLabel.isHidden = categoryProductData.khuyenMai != nil && memberStatus == 2 ? false : true
        unitPriceLabel.textColor = categoryProductData.khuyenMai != nil ? .black : .systemGreen
        discountPriceLabel.isHidden = categoryProductData.khuyenMai != nil ? false : true

        unitPriceLabel.isHidden = memberStatus == 1 ? true : false
        if categoryProductData.khuyenMai != nil {
            discountPriceLabel.isHidden = memberStatus == 1 ? true : false
        }

        if let minNumber = categoryProductData.soLuongToiThieu {
            minAmountLabel.isHidden = false
            minAmountLabel.text = "Số lượng tối thiểu: \(minNumber)"
        } else {
            minAmountLabel.isHidden = true
        }

        if let maxNumber = categoryProductData.soLuongToiDa {
            maxAmountLabel.isHidden = false
            maxAmountLabel.text = "Số lượng tối đa: \(maxNumber)"
        } else {
            maxAmountLabel.isHidden = true
        }

        productImage.sd_setImage(with: URL(string: categoryProductData.imgURL), placeholderImage: UIImage(systemName: "photo"))

        addCartButton.backgroundColor = memberStatus == 2 && categoryProductData.soLuong != 0 ? .systemGreen : .lightGray
        addCartButton.isUserInteractionEnabled = memberStatus == 2 && categoryProductData.soLuong != 0 ? true : false
        addCartButton.setTitle(categoryProductData.soLuong != 0 ? "Thêm giỏ hàng" : "Hết hàng", for: .normal)

        layoutIfNeeded()
    }
}
