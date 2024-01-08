//
//  VouchersView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 20/12/2023.
//

import FFPopup
import UIKit

class VouchersView: UIView {
    @IBOutlet var contentView: VouchersView!
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var title: UILabel!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var cancelButton: UIButton!

    var vouchers: [Voucher] = []
    var cancelOnClick: (() -> Void)?
    var voucherSelectedOnClick: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("VouchersView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        addSubview(contentView)

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = .init(width: contentView.bounds.width - 16, height: contentView.bounds.width * 1 / 4)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(VoucherCVCell.self, nibName: VoucherCVCell.identifier)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        collectionView.reloadData()
    }

    func configure(vouchers: [Voucher]) {
        self.vouchers = vouchers
    }

    @IBAction func dismiss() {
        cancelOnClick?()
    }
}

extension VouchersView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return vouchers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VoucherCVCell.identifier, for: indexPath) as! VoucherCVCell
        cell.configure(voucher: vouchers[indexPath.row])
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        voucherSelectedOnClick?(vouchers[indexPath.row].value)
    }
}
