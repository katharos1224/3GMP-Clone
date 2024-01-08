//
//  SearchResultCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 28/12/2023.
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var discountImage: UIImageView!
    @IBOutlet var coinsImage: UIImageView!

    static let identifier: String = "SearchResultCell"
    
    var cellTapOnClick: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func cellTapped() {
        cellTapOnClick?()
    }

    func configure(product: SearchData) {
        name.text = product.tenSanPham
        discountImage.isHidden = product.khuyenMai == nil ? true : false
        coinsImage.isHidden = product.banChay == 0 ? true : false
    }
}
