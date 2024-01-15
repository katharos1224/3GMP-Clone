//
//  PharmacyProfileVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Combine
import DropDown
import SDWebImage
import UIKit

final class PharmacyProfileVC: BaseViewController {
    @IBOutlet var nameField: FloatingTextField!
    @IBOutlet var pharmacyNameField: FloatingTextField!
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var emailField: FloatingTextField!
    @IBOutlet var pharmacyAddressField: FloatingTextField!
    @IBOutlet var taxField: FloatingTextField!
    @IBOutlet var newPasswordField: FloatingTextField!
    @IBOutlet var provinceField: FloatingTextField!
    @IBOutlet var imageField: FloatingTextField!

    @IBOutlet var image: UIImageView!
    @IBOutlet var warningNameLabel: UILabel!
    @IBOutlet var warningPharmacyNameLabel: UILabel!
    @IBOutlet var warningEmailLabel: UILabel!
    @IBOutlet var warningPharmacyAddressLabel: UILabel!
    @IBOutlet var warningTaxLabel: UILabel!
    @IBOutlet var warningNewPasswordLabel: UILabel!
    @IBOutlet var warningProvinceLabel: UILabel!
    @IBOutlet var warningImageLabel: UILabel!

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var rankIcon: UIImageView!
    @IBOutlet var coinLabel: UILabel!

    private var cancellables: Set<AnyCancellable> = []

    var isPasswordVisible = false
    var province: Int = 0

    var memberData: [MemberData] = []
    var updatedMemberData: [UpdatedMemberData] = []
    let dropDown = DropDown()

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }

    override func viewWillAppear(_: Bool) {}

    override func setupUI() {
        super.setupUI()
    }

    func setupData() {
        let textFields: [FloatingTextField] = [nameField, pharmacyNameField, phoneField, emailField, pharmacyAddressField, provinceField, taxField, newPasswordField]

        NetworkManager.shared.fetchProfile { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }

                let rankURL = URL(string: response.thuHangIcon ?? "")
                let imgURL = URL(string: response.img ?? "")

                self?.memberData.append(response)
                self?.province = response.tinh

                DispatchQueue.main.async {
                    self?.rankLabel.text = response.thuHang
                    self?.coinLabel.text = "\(response.coins) Coin"
                    self?.phoneField.text = response.sdt
                    self?.nameField.text = response.ten
                    self?.emailField.text = response.email
                    self?.pharmacyNameField.text = response.tenNhaThuoc
                    self?.pharmacyAddressField.text = response.diaChi
                    self?.taxField.text = response.maSoThue
                    self?.provinceField.text = response.provinces[response.tinh - 1].name
                    self?.rankIcon.sd_setImage(with: rankURL)
                    self?.image.sd_setImage(with: imgURL, placeholderImage: UIImage(systemName: "photo"), completed: { pickedImage, _, _, _ in
                        if let image = pickedImage {
                            let imageAspectRatio = image.size.width / image.size.height
                            
                            NSLayoutConstraint.activate([
                                self!.image.widthAnchor.constraint(equalTo: self!.image.heightAnchor, multiplier: imageAspectRatio)
                            ])
                            
                            self?.image.layer.cornerRadius = 10
                        }
                    })

                    textFields.forEach { textField in
                        guard let text = textField.text, text.isEmpty else {
                            textField.updatePlaceholderFrame(true)
                            return
                        }
                    }

                    self?.hideLoadingIndicator()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func logoutTapped() {
        var action: [UIAlertAction] = []

        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel, handler: nil)

        let logoutAction = UIAlertAction(title: "Đăng Xuất", style: .destructive) { _ in
            self.showLoadingIndicator()

            NetworkManager.shared.logout { [weak self] result in
                switch result {
                case .success:
                    KeychainService.deleteToken()
                    AppCoordinator.shared.completionPublisher.send()
                    self?.hideLoadingIndicator()

                    DispatchQueue.main.async {
                        self?.hide()
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }

        action.append(cancelAction)
        action.append(logoutAction)
        showAlert(title: "Xác nhận", message: "Bạn có chắc muốn đăng xuất khỏi ứng dụng?", actions: action)
    }

    @IBAction func updateTapped() {
        let labels = [warningNameLabel, warningPharmacyNameLabel, warningEmailLabel, warningPharmacyAddressLabel, warningNewPasswordLabel, warningProvinceLabel, warningTaxLabel]
        let textFields: [FloatingTextField] = [nameField, pharmacyNameField, emailField, pharmacyAddressField, newPasswordField, provinceField, taxField]

        let profile = Profile(ten: nameField.text ?? "", ten_nha_thuoc: pharmacyNameField.text ?? "", dia_chi: pharmacyAddressField.text ?? "", tinh: "\(province)", ma_so_thue: taxField.text, email: emailField.text, password: newPasswordField.text)
        let imageData = image.image!.jpegData(compressionQuality: 1.0)

        NetworkManager.shared.updateProfile(profileRequest: profile, fileData: imageData) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    let message = data.message.joined(separator: "\n")

                    for index in textFields.indices {
                        let field = textFields[index]
                        let label = labels[index]

                        if field == self?.nameField, let name = field.text, name.isEmpty || name.count > 50 {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else if field == self?.pharmacyNameField, let pharmacyName = field.text, pharmacyName.isEmpty || pharmacyName.count > 255 {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else if field == self?.pharmacyAddressField, let pharmacyAddress = field.text, pharmacyAddress.isEmpty || pharmacyAddress.count > 255 {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else if field == self?.emailField, let email = field.text, !email.isEmpty, self?.validateEmail(email) == false {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else if field == self?.taxField, let taxCode = field.text, !taxCode.isEmpty, self?.validateTaxCode(taxCode) == false {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else if field == self?.newPasswordField, let newPassword = field.text, !newPassword.isEmpty, newPassword.count < 8 || newPassword.count > 255 {
                            label?.textColor = .systemRed
                            field.bottomLineColor = .systemRed
                            field.updatedBottomLineColor(true)
                        } else {
                            label?.textColor = .clear
                            field.bottomLineColor = .systemGreen
                            field.updatedBottomLineColor(true)
                        }
                    }

                    self?.showAlert(title: "Thông báo", message: message)
                    return
                }

                var action: [UIAlertAction] = []
                let updateAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self?.popWithCrossDissolve()
                }

                let imgURL = URL(string: response.img ?? "")
                self?.updatedMemberData.append(response)
                self?.province = response.tinh

                DispatchQueue.main.async {
                    self?.phoneField.text = response.sdt
                    self?.nameField.text = response.ten
                    self?.emailField.text = response.email
                    self?.pharmacyNameField.text = response.tenNhaThuoc
                    self?.pharmacyAddressField.text = response.diaChi
                    self?.provinceField.text = response.provinces[response.tinh - 1].name
                    self?.image.sd_setImage(with: imgURL, placeholderImage: UIImage(systemName: "photo"))

                    textFields.forEach { textField in
                        guard let text = textField.text, text.isEmpty else {
                            textField.updatePlaceholderFrame(true)
                            return
                        }
                    }

                    for index in textFields.indices {
                        let field = textFields[index]
                        let label = labels[index]

                        label?.textColor = .clear
                        field.bottomLineColor = .systemGreen
                        field.updatedBottomLineColor(true)
                    }

                    action.append(updateAction)
                    self?.showAlert(title: "Thông báo", message: response.description, actions: action)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func dissmissTapped() {
        popWithCrossDissolve()
    }

    func showProvinces(sender: FloatingTextField) {
        dropDown.anchorView = sender

        NetworkManager.shared.fetchProvinces { [weak self] result in
            switch result {
            case let .success(provinces):
                var provinceName: [String] = []

                provinces.response.forEach { province in
                    provinceName.append(province.name)
                }

                self?.dropDown.dataSource = provinceName

                DispatchQueue.main.async {
                    self?.dropDown.show()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }

        dropDown.selectionAction = { [weak self] index, item in
            self?.provinceField.text = item
            self?.province = index + 1
            self?.provinceField.updatePlaceholderFrame(true)
        }
    }
}

extension PharmacyProfileVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.image.image = pickedImage
                
                let imageAspectRatio = pickedImage.size.width / pickedImage.size.height
                
                NSLayoutConstraint.deactivate(self.image.constraints)
                
                NSLayoutConstraint.activate([
                    self.image.widthAnchor.constraint(equalTo: self.image.heightAnchor, multiplier: imageAspectRatio)
                ])
                
                self.image.layer.cornerRadius = 10
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PharmacyProfileVC: FloatingTextFieldDelegate {
    func floatingTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case phoneField:
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

            return validatePhoneNumber(newText)
        default:
            return true
        }
    }

    func floatingTextFieldRightViewClick(_ textField: UITextField) {
        switch textField {
        case provinceField:
            textField.endEditing(true)
            showProvinces(sender: textField as! FloatingTextField)
        case newPasswordField:
            isPasswordVisible.toggle()
            textField.isSecureTextEntry = !isPasswordVisible

            guard let image = isPasswordVisible ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill") else { return }
            newPasswordField.rightViewSetup(rightViewImage: image)
        case imageField:
            textField.endEditing(true)

            DispatchQueue.main.async {
                self.showImagePickerOptions()
            }
        default:
            break
        }
    }

    func floatingTextFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case provinceField:
            textField.endEditing(true)
            showProvinces(sender: textField as! FloatingTextField)
        case imageField:
            textField.endEditing(true)

            DispatchQueue.main.async {
                self.showImagePickerOptions()
            }
        default:
            break
        }
    }
}
