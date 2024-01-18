//
//  AddCartSuccessfullyPopupView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 12/12/2023.
//

import Foundation
import UIKit

class AddCartSuccessfullyPopupView: UIView {
    @IBOutlet var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("AddCartSuccessfullyPopupView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }
}
