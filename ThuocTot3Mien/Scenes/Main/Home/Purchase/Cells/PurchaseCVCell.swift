//
//  PurchaseCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 15/12/2023.
//

import UIKit

class PurchaseCVCell: UICollectionViewCell {
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var productView: ProductInfoView!

    var cellTapOnclick: (() -> Void)?

    static let identifier: String = "PurchaseCVCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)

        productView.layer.cornerRadius = 10.0
        productView.tagStack.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productView.tagStack.removeAllArrangedSubviews()
        amountLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    @objc private func cellTapped() {
        cellTapOnclick?()
    }

    func configure(productData: CartProduct) {
        productView.configure(productData: productData)
        amountLabel.text = "x\(productData.soLuong)"
    }
    
    func configure(productData: OrderedProductItem) {
        productView.configure(productData: productData)
        amountLabel.text = "x\(productData.soLuong)"
    }
}
