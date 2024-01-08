//
//  HomepageHeaderCRView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import UIKit

class HomepageHeaderCRView: UICollectionReusableView {
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var label: UILabel!

    static let identifier: String = "HomepageHeaderCRView"

    var onClick: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func imageViewTapped() {
        onClick?()
    }

    func configure(title: String) {
        label.text = title
    }
}
