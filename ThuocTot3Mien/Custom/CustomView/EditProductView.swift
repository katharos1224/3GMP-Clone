//
//  EditProductView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 23/01/2024.
//

import UIKit

class EditProductView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var agreeButton: UIButton!
    
    var agreeOnClick: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("EditProductView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        contentView.layer.cornerRadius = 10
    }

    @IBAction func agreeTapped() {
        agreeOnClick?()
    }
}
