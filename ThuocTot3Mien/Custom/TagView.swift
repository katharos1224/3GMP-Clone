//
//  TagView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 11/12/2023.
//

import Foundation
import UIKit

class TagView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var tagLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        Bundle.main.loadNibNamed("TagView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
    }

    func configure(name: String) {
        tagLabel.text = name
    }
}
