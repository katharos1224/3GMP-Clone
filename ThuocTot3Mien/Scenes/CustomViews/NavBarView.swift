//
//  NavBarView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 04/01/2024.
//

import UIKit

class NavBarView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var dismiss: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("NavBarView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius: CGFloat = 0
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer
//        clearImage.isHidden = true
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    @IBAction func dismissVC() {
        dismiss?()
    }

}
