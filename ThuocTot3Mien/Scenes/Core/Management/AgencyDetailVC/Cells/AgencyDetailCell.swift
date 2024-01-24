//
//  AgencyDetailCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import UIKit
import SwipeCellKit

class AgencyDetailCell: SwipeCollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sizeView: UIView!
    
    static let identifier: String = "AgencyDetailCell"

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
        sizeView.layer.cornerRadius = sizeView.frame.size.height / 2
    }

    func configure(data: AgencyCategoryType) {
        nameLabel.text = data.name
        sizeLabel.text = "\(data.size)"
    }

}
