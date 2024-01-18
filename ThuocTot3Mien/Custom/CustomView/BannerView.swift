//
//  BannerView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import UIKit

class BannerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var clearImage: UIImageView!
    @IBOutlet var stackBar: UIStackView!

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
        Bundle.main.loadNibNamed("BannerView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius: CGFloat = 33
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer
        clearImage.isHidden = true
    }

    func configure(title: String) {
        label.text = title
    }

    @IBAction func dismissVC() {
        dismiss?()
    }
}
