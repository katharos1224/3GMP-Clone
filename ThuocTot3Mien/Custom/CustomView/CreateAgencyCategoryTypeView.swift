//
//  CreateAgencyCategoryTypeView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import UIKit

class CreateAgencyCategoryTypeView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var addTextField: FloatingTextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    var addOnClick: (() -> Void)?
    var editOnClick: (() -> Void)?
    var dismissOnClick: (() -> Void)?
    
    var isEdit: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("CreateAgencyCategoryTypeView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        contentView.layer.cornerRadius = 10
        contentView.layoutSubviews()
    }

    @IBAction func addTapped() {
        isEdit ? editOnClick?() : addOnClick?()
    }
    
    @IBAction func dismissTapped() {
        dismissOnClick?()
    }
}
