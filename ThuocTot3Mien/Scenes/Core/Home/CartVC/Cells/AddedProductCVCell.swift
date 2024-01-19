//
//  AddedProductCVCell.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 11/12/2023.
//

import UIKit

class AddedProductCVCell: UICollectionViewCell {
    @IBOutlet var productView: ProductInfoView!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var minusImage: UIImageView!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var checkmarkImage: UIImageView!
    @IBOutlet var deleteImage: UIImageView!

    static let identifier: String = "AddedProductCVCell"

    var isChecked: Bool = true

    var cellTapOnclick: (() -> Void)?
    var checkOnClick: (() -> Void)?
    var deleteOnClick: (() -> Void)?
    var minusOnClick: (() -> Void)?
    var plusOnClick: (() -> Void)?
    var showPopupOnClick: (() -> Void)?

    var cartData: CartProduct?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)

        productView.layer.cornerRadius = 10.0

        let checkTap = UITapGestureRecognizer(target: self, action: #selector(checkedTapped))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
        let minusTap = UITapGestureRecognizer(target: self, action: #selector(minusTapped))
        let plusTap = UITapGestureRecognizer(target: self, action: #selector(plusTapped))

        checkmarkImage.addGestureRecognizer(checkTap)
        deleteImage.addGestureRecognizer(deleteTap)
        minusImage.addGestureRecognizer(minusTap)
        plusImage.addGestureRecognizer(plusTap)

        amountField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productView.tagStack.removeAllArrangedSubviews()
        productView.discountPriceLabel.text = ""
        productView.bonusCoinsLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    @objc private func cellTapped() {
        cellTapOnclick?()
    }

    @objc private func checkedTapped() {
        checkOnClick?()
    }

    @objc private func deleteTapped() {
        deleteOnClick?()
    }

    @objc private func minusTapped() {
        minusOnClick?()
    }

    @objc private func plusTapped() {
        plusOnClick?()
    }

    func configure(productData: CartProduct) {
        cartData = productData
        productView.tagStack.removeAllArrangedSubviews()
        productView.configure(productData: productData)
        amountField.text = "\(productData.soLuong)"
        checkmarkImage.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
    }

    func toggleCheckmark() {
        checkmarkImage.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
    }
}

extension AddedProductCVCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        endEditing(true)
        showPopupOnClick?()
    }

    func textFieldDidEndEditing(_: UITextField) {
        endEditing(true)
//        updateProductData(textField: textField)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        endEditing(true)
//        updateProductData(textField: textField)
        return true
    }

    func updateProductData(textField: UITextField) {
        guard let cartData = cartData, var number = Int(textField.text!), number != 0 else {
            amountField.text = "\(String(describing: cartData!.soLuong))"
            return
        }

        if let minAmount = cartData.soLuongToiThieu {
            if number < minAmount {
                number = minAmount
                amountField.text = "\(minAmount)"
            }
        }

        if let maxAmount = cartData.soLuongToiDa {
            if number > maxAmount {
                number = maxAmount
                amountField.text = "\(maxAmount)"
            }
        }

        NetworkManager.shared.updateCart(id: cartData.id, number: number) { result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                NotificationCenter.default.post(name: Notification.Name("TextFieldDidChange"), object: nil, userInfo: ["result": response])
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
