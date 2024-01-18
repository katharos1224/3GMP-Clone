//
//  VoucherCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 20/12/2023.
//

import UIKit

class VoucherCVCell: UICollectionViewCell {
    static let identifier: String = "VoucherCVCell"

    @IBOutlet var containerView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowRadius = 6.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        containerView.layer.cornerRadius = 20
    }

    func configure(voucher: Voucher) {
        titleLabel.text = voucher.title.decodeHTML()
        contentLabel.text = voucher.content.decodeHTML()
    }
}
