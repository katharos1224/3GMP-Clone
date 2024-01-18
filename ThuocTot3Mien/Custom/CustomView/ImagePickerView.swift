//
//  ImagePickerView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 17/01/2024.
//

import UIKit

class ImagePickerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var cameraStack: UIStackView!
    @IBOutlet var libraryStack: UIStackView!

    var cameraOnClick: (() -> Void)?
    var libraryOnClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("ImagePickerView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)

        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        let librarytap = UITapGestureRecognizer(target: self, action: #selector(libraryTapped))
        cameraStack.addGestureRecognizer(cameraTap)
        libraryStack.addGestureRecognizer(librarytap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        contentView.layer.cornerRadius = 10
    }

    @objc private func cameraTapped() {
        cameraOnClick?()
    }

    @objc private func libraryTapped() {
        libraryOnClick?()
    }
}
