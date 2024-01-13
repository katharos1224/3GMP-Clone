//
//  ManagementCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/01/2024.
//

import UIKit

class ManagementCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UILabel!

    static let identifier: String = "ManagementCell"

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

    func configure(item: MenuItem) {
        image.image = UIImage(systemName: item.imageName)
        title.text = item.title
    }
}
