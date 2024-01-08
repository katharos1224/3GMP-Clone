//
//  OnboardingCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import SDWebImage
import UIKit

class OnboardingCVCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!

    static let identifier: String = "OnboardingCVCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        image.layer.cornerRadius = 10.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowRadius = 3.0
    }

    func configure(index: Int) {
        image.image = UIImage(named: "onboarding_\(index)")
    }

    func configureBanner(imgURL: String) {
        image.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(systemName: "photo"))
    }
}
