//
//  IndicatorCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 19/01/2024.
//

import UIKit

class IndicatorCell: UICollectionViewCell {
    static let identifier: String = "IndicatorCell"

    var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .systemGreen
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView.addSubview(indicator)
        indicator.center = contentView.center
        indicator.startAnimating()
    }
}
