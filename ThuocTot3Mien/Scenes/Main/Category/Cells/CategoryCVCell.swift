//
//  CategoryCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import UIKit

class CategoryCVCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!

    static let identifier: String = "CategoryCVCell"

    var cellTapOnClick: (() -> Void)?

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

    @objc private func cellTapped() {
        cellTapOnClick?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        layer.cornerRadius = frame.size.height / 2
    }

    func configure(name: String) {
        label.text = name
    }
}
