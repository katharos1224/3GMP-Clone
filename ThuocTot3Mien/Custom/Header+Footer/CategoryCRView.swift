//
//  CategoryCRView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import SDWebImage
import UIKit

class CategoryCRView: UICollectionReusableView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var icon: UIImageView!
    
    var onClick: (() -> Void)?

    static let identifier: String = "CategoryCRView"

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = containerView.frame.size.height / 2
    }

    @objc private func imageViewTapped() {
        onClick?()
    }

    func configure(image: String, name: String) {
        self.image.sd_setImage(with: URL(string: image), placeholderImage: UIImage(systemName: "questionmark.circle.fill"))
        self.name.text = name
    }
}
