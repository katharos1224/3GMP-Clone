//
//  HistoryCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 03/01/2024.
//

import UIKit

class HistoryCVCell: UICollectionViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var totalMoney: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    static let identifier: String = "HistoryCVCell"
    
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

    func configure(order: OrderHistoryItem) {
        if let id = order.id,
           let createdDate = order.createdAt,
           let address = order.diaChi,
           let totalMoney = order.tongTien,
           let status = order.trangThai == 0 ? "Chờ thanh toán" : "Đã thanh toán" {
            self.id.text = "\(id)"
            self.createdDate.text = "\(createdDate)"
            self.address.text = "\(address)"
            self.totalMoney.text = "\(totalMoney.formattedWithSeparator()) VND"
            self.status.text = "\(status)"
            
            self.status.textColor = order.trangThai == 0 ? .systemRed : .systemGreen
            self.totalMoney.textColor = order.trangThai == 0 ? .systemRed : .systemGreen
            self.statusImage.tintColor = order.trangThai == 0 ? .systemRed : .systemGreen
        }
    }
}
