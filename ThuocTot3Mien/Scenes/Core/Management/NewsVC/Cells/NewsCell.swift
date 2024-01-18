//
//  NewsCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import SDWebImage
import UIKit

class NewsCell: UICollectionViewCell {
    @IBOutlet var publishDate: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    static let identifier: String = "NewsCell"

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

    func configure(item: NewsItem) {
        publishDate.text = item.publishDate.convertDateFormat(from: "yyyy-MM-dd", to: "dd/MM/yyyy")
        title.text = item.title
        descriptionLabel.text = item.description
        let url = URL(string: item.imageURL)
        image.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
