//
//  BannerView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import UIKit

class BannerView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var clearImage: UIImageView!
    @IBOutlet weak var stackBar: UIStackView!
    
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
