//
//  PaymentView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 15/12/2023.
//

import FFPopup
import Foundation
import IQKeyboardManager
import UIKit
import WebKit

protocol PaymentViewDelegate: AnyObject {
    func didTapCreatePayment(withURL url: URL)
}

class PaymentView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var useOnlineCheckmark: UIImageView!
    @IBOutlet var totalNumberLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var voucherField: FloatingTextField!
    @IBOutlet var applyVoucherButton: UIButton!
    @IBOutlet var useCoinsSwitch: UISwitch!
    @IBOutlet var nameField: FloatingTextField!
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var emailField: FloatingTextField!
    @IBOutlet var taxField: FloatingTextField!
    @IBOutlet var addressField: FloatingTextField!
    @IBOutlet var noteField: FloatingTextField!
    @IBOutlet var givenCoinsLabel: UILabel!
    @IBOutlet var warningVoucherLabel: UILabel!
    @IBOutlet var usingCoinsLabel: UILabel!
    @IBOutlet var reductionRateLabel: UILabel!
    @IBOutlet var createPaymentButton: UIButton!

    @IBOutlet var nameWarningLabel: UILabel!
    @IBOutlet var phoneWarningLabel: UILabel!
    @IBOutlet var emailWarningLabel: UILabel!
    @IBOutlet var taxWarningLabel: UILabel!
    @IBOutlet var addressWarningLabel: UILabel!

    weak var delegate: PaymentViewDelegate?

    var vouchers: [Voucher] = []
    var cartIDs: [Int] = []
    var coinStatus: Int = 0
    var totalNumber: Int = 0
    var totalPrice: Int = 0
    var money: Int = 0
    var finalPrice: Int = 0
    var reductionRate: Double = 0.0

    var showFailedMessage: ((String) -> Void)?
    var useOnlinePaymentOnClick: (() -> Void)?
    var returnHomepageOnClick: (() -> Void)?
    var useCoinsOnClick: (() -> Void)?
    var useOnlinePayment: Bool = false
    var useVoucher: Bool = false
    var availableVoucher: Bool = false

    let vouchersContentView: VouchersView = {
        let width = Constants.WIDTH_SCREEN - 32
        let height = width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = VouchersView(frame: frame)
        return view
    }()

    var vouchersPopupView = FFPopup()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        Bundle.main.loadNibNamed("PaymentView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)

        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        contentView.layer.mask = maskLayer

        createPaymentButton.layer.cornerRadius = createPaymentButton.frame.size.height / 2

        let useCoinsTap = UITapGestureRecognizer(target: self, action: #selector(useOnlinePaymentTapped))
        useCoinsSwitch.addTarget(self, action: #selector(useCoinsSwitchChanged(_:)), for: .valueChanged)
        useOnlineCheckmark.addGestureRecognizer(useCoinsTap)

        if let name = UserDefaults.standard.string(forKey: "name"),
           let phone = UserDefaults.standard.string(forKey: "phone"),
           let address = UserDefaults.standard.string(forKey: "address")
        {
            nameField.text = name
            phoneField.text = phone
            addressField.text = address

            if let email = UserDefaults.standard.string(forKey: "email") {
                emailField.text = email
            }
        }

        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    @objc func useCoinsSwitchChanged(_ sender: UISwitch) {
        coinStatus = sender.isOn ? 1 : 0
        usingCoinsLabel.isHidden = coinStatus == 1 ? false : true

        NetworkManager.shared.fetchDiscount(cartIDs: cartIDs, coinStatus: coinStatus, voucherValue: voucherField.text ?? "") { [self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }

                availableVoucher = response.voucherAvailable == 1 ? true : false

                DispatchQueue.main.async { [self] in
                    warningVoucherLabel.isHidden = response.voucherDescription == "" ? true : false
                    usingCoinsLabel.isHidden = response.coinDescription == "" ? true : false

                    warningVoucherLabel.text = response.voucherDescription
                    usingCoinsLabel.text = response.coinDescription

                    warningVoucherLabel.textColor = response.voucherAvailable == 1 ? .systemGreen : .systemRed
                    usingCoinsLabel.textColor = response.coinAvailable == 1 ? .systemGreen : .systemRed

                    money = response.money
                    if useOnlinePayment {
                        let newPrice = (totalPrice - money) - Int(round(Double((totalPrice - money) / 100) * reductionRate))
                        totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                        finalPrice = newPrice
                    } else {
                        totalPriceLabel.text = "\((totalPrice - money).formattedWithSeparator()) VNĐ"
                        finalPrice = totalPrice - money
                    }

                    layoutIfNeeded()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    @objc private func useOnlinePaymentTapped() {
        useOnlinePayment.toggle()
        useOnlineCheckmark.image = UIImage(systemName: useOnlinePayment ? "checkmark.square.fill" : "square")
        useOnlineCheckmark.tintColor = useOnlinePayment ? .systemGreen : .placeholderText

        if useOnlinePayment {
            if availableVoucher {
                let newPrice = (totalPrice - money) - Int(round(Double((totalPrice - money) / 100) * reductionRate))
                totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                finalPrice = newPrice
            } else {
                let newPrice = totalPrice - Int(round(Double(totalPrice / 100) * reductionRate))
                totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                finalPrice = newPrice
            }
        } else {
            if availableVoucher {
                totalPriceLabel.text = "\((totalPrice - money).formattedWithSeparator()) VNĐ"
                finalPrice = totalPrice - money
            } else {
                totalPriceLabel.text = "\(totalPrice.formattedWithSeparator()) VNĐ"
                finalPrice = totalPrice
            }
        }
    }

    @IBAction func showVouchers() {
        vouchersPopupView = FFPopup(contentView: vouchersContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        vouchersContentView.configure(vouchers: vouchers)

        vouchersContentView.collectionView.reloadData()
        let contentHeight = vouchersContentView.collectionView.collectionViewLayout.collectionViewContentSize.height
        vouchersContentView.heightConstraint.constant = contentHeight
        let height = contentHeight + vouchersContentView.title.bounds.height + vouchersContentView.cancelButton.bounds.height + 64
        let width = Constants.WIDTH_SCREEN - 32
        vouchersContentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        vouchersContentView.collectionView.layoutIfNeeded()

        vouchersContentView.voucherSelectedOnClick = { [self] voucherValue in
            vouchersPopupView.dismiss(animated: true)

            NetworkManager.shared.fetchDiscount(cartIDs: cartIDs, coinStatus: coinStatus, voucherValue: voucherValue) { [self] result in
                switch result {
                case let .success(data):
                    guard let response = data.response else { return }

                    useVoucher = true
                    availableVoucher = response.voucherAvailable == 1 ? true : false

                    DispatchQueue.main.async { [self] in
                        warningVoucherLabel.isHidden = response.voucherDescription == "" ? true : false
                        usingCoinsLabel.isHidden = response.coinDescription == "" ? true : false

                        warningVoucherLabel.text = response.voucherDescription
                        usingCoinsLabel.text = response.coinDescription

                        warningVoucherLabel.textColor = response.voucherAvailable == 1 ? .systemGreen : .systemRed
                        usingCoinsLabel.textColor = response.coinAvailable == 1 ? .systemGreen : .systemRed

                        applyVoucherButton.setTitle(useVoucher ? "Xoá" : "Áp dụng", for: .normal)
                        applyVoucherButton.setTitleColor(useVoucher ? .systemRed : .systemGreen, for: .normal)
                        voucherField.text = voucherValue
                        voucherField.textColor = useVoucher ? .placeholderText : .label
                        voucherField.isUserInteractionEnabled = useVoucher ? false : true

                        money = response.money

                        if useOnlinePayment {
                            if response.voucherAvailable == 1 {
                                let newPrice = (totalPrice - money) - Int(round(Double((totalPrice - money) / 100) * reductionRate))
                                totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                                finalPrice = newPrice
                            } else {
                                let newPrice = totalPrice - Int(round(Double(totalPrice / 100) * reductionRate))
                                totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                                finalPrice = newPrice
                            }
                        } else {
                            if response.voucherAvailable == 1 {
                                totalPriceLabel.text = "\((totalPrice - money).formattedWithSeparator()) VNĐ"
                                finalPrice = totalPrice - money
                            } else {
                                totalPriceLabel.text = "\(totalPrice.formattedWithSeparator()) VNĐ"
                                finalPrice = totalPrice
                            }
                        }
                    }

                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }

        vouchersContentView.cancelOnClick = { [self] in
            vouchersPopupView.dismiss(animated: true)
        }

        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        DispatchQueue.main.async {
            self.vouchersPopupView.show(layout: layout)
            self.layoutIfNeeded()
        }
    }

    @IBAction func applyVoucherTapped() {
        guard let voucherValue = voucherField.text, voucherValue != "" else {
            useVoucher = false
            return
        }

        NetworkManager.shared.fetchDiscount(cartIDs: cartIDs, coinStatus: useCoinsSwitch.isOn ? 1 : 0, voucherValue: voucherValue) { [self] result in

            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                print(response.money)

                useVoucher.toggle()

                DispatchQueue.main.async { [self] in
                    warningVoucherLabel.isHidden = response.voucherDescription == "" ? true : false
                    usingCoinsLabel.isHidden = response.coinDescription == "" ? true : false

                    warningVoucherLabel.text = response.voucherDescription
                    usingCoinsLabel.text = response.coinDescription

                    warningVoucherLabel.textColor = response.voucherAvailable == 1 ? .systemGreen : .systemRed
                    usingCoinsLabel.textColor = response.coinAvailable == 1 ? .systemGreen : .systemRed

                    applyVoucherButton.setTitle(useVoucher ? "Xoá" : "Áp dụng", for: .normal)
                    applyVoucherButton.setTitleColor(useVoucher ? .systemRed : .systemGreen, for: .normal)
                    voucherField.text = useVoucher ? voucherValue : ""
                    voucherField.textColor = useVoucher ? .placeholderText : .label
                    voucherField.isUserInteractionEnabled = useVoucher ? false : true
                    warningVoucherLabel.isHidden = useVoucher ? false : true

                    money = useVoucher ? response.money : 0

                    if useOnlinePayment {
                        if response.voucherAvailable == 1 {
                            let newPrice = (totalPrice - money) - Int(round(Double((totalPrice - money) / 100) * reductionRate))
                            totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                            finalPrice = newPrice
                        } else {
                            let newPrice = totalPrice - Int(round(Double(totalPrice / 100) * reductionRate))
                            totalPriceLabel.text = "\(newPrice.formattedWithSeparator()) VNĐ"
                            finalPrice = newPrice
                        }
                    } else {
                        if response.voucherAvailable == 1 {
                            totalPriceLabel.text = "\((totalPrice - money).formattedWithSeparator()) VNĐ"
                            finalPrice = totalPrice - money
                        } else {
                            totalPriceLabel.text = "\(totalPrice.formattedWithSeparator()) VNĐ"
                            finalPrice = totalPrice
                        }
                    }
                }

            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func createPaymentTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let address = addressField.text, !address.isEmpty
        else {
            if nameField.text == "" {
                nameWarningLabel.textColor = .systemRed
                nameField.bottomLineColor = .systemRed
                nameField.updatedBottomLineColor(true)

                showFailedMessage?("Vui lòng nhập tên")
            }

            if phoneField.text == "" {
                phoneWarningLabel.textColor = .systemRed
                phoneField.bottomLineColor = .systemRed
                phoneField.updatedBottomLineColor(true)

                showFailedMessage?("Vui lòng nhập số điện thoại")
            }

            if addressField.text == "" {
                addressWarningLabel.textColor = .systemRed
                addressField.bottomLineColor = .systemRed
                addressField.updatedBottomLineColor(true)

                showFailedMessage?("Vui lòng nhập địa chỉ")
            }

            return
        }

        nameWarningLabel.textColor = .clear
        nameField.bottomLineColor = .systemGreen
        nameField.updatedBottomLineColor(true)

        phoneWarningLabel.textColor = .clear
        phoneField.bottomLineColor = .systemGreen
        phoneField.updatedBottomLineColor(true)

        addressWarningLabel.textColor = .clear
        addressField.bottomLineColor = .systemGreen
        addressField.updatedBottomLineColor(true)

        let device = PlatformManager.getPlatform()
        let onlineTransfer = useOnlinePayment ? 1 : 0
        let coin = useCoinsSwitch.isOn ? 1 : 0

        let paymentParams = Payment(dataId: cartIDs, device: device, ten: name, sdt: phone, email: emailField.text, diaChi: address, maSoThue: taxField.text, ghiChu: noteField.text, ckTruoc: onlineTransfer, voucher: voucherField.text, coin: coin, totalPrice: String(finalPrice))

        if useOnlinePayment {
            NetworkManager.shared.fetchOnlinePayment(params: paymentParams) { [weak self] result in
                switch result {
                case let .success(data):
                    guard let response = data.response else {
                        let message = data.message
                        let messageString = message.joined(separator: "\n")

                        self?.showFailedMessage?(messageString)

                        return
                    }

                    if let url = URL(string: response.urlPayment) {
                        self?.delegate?.didTapCreatePayment(withURL: url)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        } else {
            NetworkManager.shared.fetchCODPayment(params: paymentParams) { [weak self] result in

                switch result {
                case let .success(data):
                    guard let _ = data.response else {
                        let message = data.message
                        let messageString = message.joined(separator: "\n")

                        self?.showFailedMessage?(messageString)

                        return
                    }

                    DispatchQueue.main.async {
                        self?.returnHomepageOnClick?()
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
