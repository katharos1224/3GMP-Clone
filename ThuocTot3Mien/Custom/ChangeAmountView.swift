//
//  ChangeAmountView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 17/01/2024.
//

import UIKit

class ChangeAmountView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textField: FloatingTextField!
    
    
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
        Bundle.main.loadNibNamed("ChangeAmountView", owner: self)
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
