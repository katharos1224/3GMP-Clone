//
//  ContactCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/01/2024.
//

import SDWebImage
import UIKit

class ContactCell: UICollectionViewCell {
    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!

    static let identifier: String = "ContactCell"

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

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        layer.cornerRadius = 10
    }

    @objc private func cellTapped() {
        cellTapOnClick?()
    }

    func configure(item: ContactMethod) {
        icon.sd_setImage(with: URL(string: item.icon), placeholderImage: UIImage(systemName: "photo"))
        name.text = item.name
    }
}
