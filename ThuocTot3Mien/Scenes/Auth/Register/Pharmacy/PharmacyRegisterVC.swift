//
//  PharmacyRegisterVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import Combine
import DropDown
import UIKit
import FFPopup

final class PharmacyRegisterVC: BaseViewController {
    @IBOutlet var termsOfUseButton: UIButton!

    @IBOutlet var nameField: FloatingTextField!
    @IBOutlet var pharmacyNameField: FloatingTextField!
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var emailField: FloatingTextField!
    @IBOutlet var pharmacyAddressField: FloatingTextField!
    @IBOutlet var passwordField: FloatingTextField!
    @IBOutlet var provinceField: FloatingTextField!
    @IBOutlet var businessLicenseImageField: FloatingTextField!

    @IBOutlet var businessLicenseImage: UIImageView!
    @IBOutlet var warningNameLabel: UILabel!
    @IBOutlet var warningPharmacyNameLabel: UILabel!
    @IBOutlet var warningPhoneLabel: UILabel!
    @IBOutlet var warningEmailLabel: UILabel!
    @IBOutlet var warningPharmacyAddressLabel: UILabel!
    @IBOutlet var warningPasswordLabel: UILabel!
    @IBOutlet var warningProvinceLabel: UILabel!
    @IBOutlet var warningImageLabel: UILabel!

    let viewModel = AuthViewModel()

    var isPasswordVisible = false
    var isCustomer: Bool = true
    var province: Int = 0

    private var cancellables: Set<AnyCancellable> = []

    let dropDown = DropDown()

    let imagePickerContentView: ImagePickerView = {
        let width = (4 / 5) * UIScreen.main.bounds.size.width
        let height = width * (4 / 5)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = ImagePickerView(frame: frame)
        return view
    }()

    var imagePickerPopupView = FFPopup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViewModel()
    }

    override func setupUI() {
        let title = "Điều khoản sử dụng"
        let attributedTitle = NSAttributedString(string: title, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        termsOfUseButton.setAttributedTitle(attributedTitle, for: .normal)

        let textFields: [FloatingTextField] = [nameField, pharmacyNameField, phoneField, pharmacyAddressField, emailField, passwordField, provinceField, businessLicenseImageField]

        textFields.forEach { textField in
            guard let text = textField.text, text.isEmpty else {
                textField.updatePlaceholderFrame(true)
                return
            }
        }
    }
    
    func showImagePickerPopup() {
        imagePickerPopupView = FFPopup(contentView: imagePickerContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: true)
        
        imagePickerContentView.cameraOnClick = {
            self.showImagePicker(sourceType: .camera)
        }
        
        imagePickerContentView.libraryOnClick = {
            self.showImagePicker(sourceType: .photoLibrary)
        }
        
        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        imagePickerPopupView.show(layout: layout)
    }

    func dismissPopup() {
        imagePickerPopupView.dismiss(animated: true)
    }

    @IBAction func dismiss() {
        popWithCrossDissolve()
    }

    @IBAction func registerTapped() {
        let labels = [warningNameLabel, warningPharmacyNameLabel, warningPhoneLabel, warningPharmacyAddressLabel, warningPasswordLabel, warningProvinceLabel, warningImageLabel]

        let fields: [FloatingTextField] = [nameField, pharmacyNameField, phoneField, pharmacyAddressField, passwordField, provinceField, businessLicenseImageField]

        guard let name = nameField.text, !name.isEmpty,
              let pharmacy = pharmacyNameField.text, !pharmacy.isEmpty,
              let phone = phoneField.text, !phone.isEmpty, phone.count == 10,
              let email = emailField.text,
              let address = pharmacyAddressField.text, !address.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let province = provinceField.text, !province.isEmpty,
              businessLicenseImage.image != UIImage(named: "photo")
        else {
            for index in fields.indices {
                let field = fields[index]
                let label = labels[index]

                if !field.text!.isEmpty {
                    label?.textColor = .clear
                    field.bottomLineColor = .systemGreen
                    field.updatedBottomLineColor(true)

                    if field == phoneField, field.text!.count < 10 {
                        field.bottomLineColor = .systemRed
                        field.updatedBottomLineColor(true)

                        showAlert(title: "Oops", message: "Số điện thoại phải có 10 chữ số!")
                    } else if field == passwordField, field.text!.count < 8 {
                        field.bottomLineColor = .systemRed
                        field.updatedBottomLineColor(true)

                        showAlert(title: "Opps", message: "Mật khẩu phải có ít nhất 8 ký tự và không chứa ký tự đặc biệt!")
                    }
                } else if field != businessLicenseImageField {
                    label?.textColor = .systemRed
                    field.bottomLineColor = .systemRed
                    field.updatedBottomLineColor(true)
                } else {
                    warningImageLabel.textColor = businessLicenseImage.image != UIImage(systemName: "photo") ? .clear : .systemRed
                }
            }

            if let email = emailField.text, !email.isEmpty, !validateEmail(email) {
                emailField.bottomLineColor = .systemRed
                emailField.updatedBottomLineColor(true)

                showAlert(title: "Opps", message: "Vui lòng nhập đúng định dạng email!")
            } else {
                emailField.bottomLineColor = .systemGreen
                emailField.updatedBottomLineColor(true)
            }

            return
        }

        for index in labels.indices {
            let label = labels[index]
            let field = fields[index]

            label?.textColor = .clear
            field.bottomLineColor = .systemGreen
            field.updatedBottomLineColor(true)

            warningImageLabel.textColor = businessLicenseImage.image != UIImage(systemName: "photo") ? .clear : .systemRed
        }

        if let image = businessLicenseImage.image, let imageData = image.jpegData(compressionQuality: 1.0), image != UIImage(systemName: "photo") {
            let pharmacy = Pharmacy(ten: name, ten_nha_thuoc: pharmacy, dia_chi: address, tinh: "\(self.province)", sdt: phone, email: email, password: password)

            setupRegisterObserver(pharmacy: pharmacy, imageData: imageData)
        }
    }

    private func setupRegisterObserver(pharmacy: Pharmacy, imageData: Data) {
        viewModel.registerPharmacy(pharmacy: pharmacy, imageData: imageData)
            .sink { _ in }
            .store(in: &cancellables)
    }

    private func setupViewModel() {
        viewModel.updateUI = { [weak self] in
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self?.hide()
            }

            DispatchQueue.main.async {
                self?.showAlert(title: "Đăng ký thành công", message: "Đăng ký nhà thuốc thành công.", actions: [action])
            }
        }

        viewModel.showResponseMessage = { [weak self] responseMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Đăng ký không thành công", message: responseMessage)
            }
        }

        viewModel.showLoading = { [weak self] _ in
            DispatchQueue.main.async {
//                self?.showLoadingIndicator(isLoading)
            }
        }
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

extension PharmacyRegisterVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.businessLicenseImage.image = pickedImage
                
                let imageAspectRatio = pickedImage.size.width / pickedImage.size.height
                
                NSLayoutConstraint.deactivate(self.businessLicenseImage.constraints)
                
                NSLayoutConstraint.activate([
                    self.businessLicenseImage.widthAnchor.constraint(equalTo: self.businessLicenseImage.heightAnchor, multiplier: imageAspectRatio)
                ])
                
                self.businessLicenseImage.layer.cornerRadius = 10
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PharmacyRegisterVC: FloatingTextFieldDelegate {
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
        case passwordField:
            isPasswordVisible.toggle()
            textField.isSecureTextEntry = !isPasswordVisible

            guard let image = isPasswordVisible ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill") else { return }
            passwordField.rightViewSetup(rightViewImage: image)
        case businessLicenseImageField:
            textField.endEditing(true)

            DispatchQueue.main.async {
//                self.showImagePickerOptions()
                self.showImagePickerPopup()
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
        case businessLicenseImageField:
            textField.endEditing(true)

            DispatchQueue.main.async {
                self.showImagePickerOptions()
            }
        default:
            break
        }
    }
}
