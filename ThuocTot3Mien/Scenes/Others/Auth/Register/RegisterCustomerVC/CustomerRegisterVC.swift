//
//  CustomerRegisterVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import Combine
import DropDown
import FFPopup
import UIKit

final class CustomerRegisterVC: BaseViewController {
    @IBOutlet var termsOfUseButton: UIButton!
    @IBOutlet var nameField: FloatingTextField!
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var emailField: FloatingTextField!
    @IBOutlet var addressField: FloatingTextField!
    @IBOutlet var passwordField: FloatingTextField!
    @IBOutlet var provinceField: FloatingTextField!
    @IBOutlet var pharmacyField: FloatingTextField!
    @IBOutlet var avatarField: FloatingTextField!

    @IBOutlet var avatarImage: UIImageView!

    @IBOutlet var warningNameLabel: UILabel!
    @IBOutlet var warningPhoneLabel: UILabel!
    @IBOutlet var warningAddressLabel: UILabel!
    @IBOutlet var warningPasswordLabel: UILabel!
    @IBOutlet var warningProvinceLabel: UILabel!
    @IBOutlet var warningPharmacyLabel: UILabel!
    @IBOutlet var warningImageLabel: UILabel!

    let viewModel = AuthViewModel()

    var isPasswordVisible = false
    var isCustomer: Bool = true
    var provinceID: Int = 0
    var agencyID: Int?

    private var cancellables: Set<AnyCancellable> = []

    let dropDown = DropDown()

    let imagePickerContentView: ImagePickerView = {
        let width = (4 / 5) * Constants.WIDTH_SCREEN
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

        let textFields: [FloatingTextField] = [nameField, phoneField, addressField, emailField, passwordField, provinceField, pharmacyField, avatarField]

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
        let labels = [warningNameLabel, warningPhoneLabel, warningAddressLabel, warningPasswordLabel, warningProvinceLabel, warningPharmacyLabel, warningImageLabel]

        let fields: [FloatingTextField] = [nameField, phoneField, addressField, passwordField, provinceField, pharmacyField, avatarField]

        guard let name = nameField.text, !name.isEmpty,
              let phone = phoneField.text, !phone.isEmpty, phone.count == 10,
              let email = emailField.text,
              let address = addressField.text, !address.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let province = provinceField.text, !province.isEmpty,
              let pharmacy = pharmacyField.text, !pharmacy.isEmpty,
              avatarImage.image != UIImage(systemName: "rectangle.slash")
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
                } else if field != avatarField {
                    label?.textColor = .systemRed
                    field.bottomLineColor = .systemRed
                    field.updatedBottomLineColor(true)
                } else {
                    warningImageLabel.textColor = avatarImage.image != UIImage(systemName: "photo") ? .clear : .systemRed
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

            warningImageLabel.textColor = avatarImage.image != UIImage(systemName: "photo") ? .clear : .systemRed
        }

        if let image = avatarImage.image, let imageData = image.jpegData(compressionQuality: 1.0), image != UIImage(systemName: "photo") {
            let customer = Customer(ten: name, id_agency: String(describing: agencyID!), dia_chi: address, tinh: "\(provinceID)", sdt: phone, email: email, password: password)

            setupRegisterObserver(customer: customer, imageData: imageData)
        }
    }

    private func setupRegisterObserver(customer: Customer, imageData: Data) {
        viewModel.registerCustomer(customer: customer, imageData: imageData)
            .sink { _ in }
            .store(in: &cancellables)
    }

    private func setupViewModel() {
        viewModel.updateUI = { [weak self] in
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                self?.hide()
            }

            DispatchQueue.main.async {
                self?.showAlert(title: "Đăng ký thành công", message: "Đăng ký khách hàng thành công.", actions: [action])
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

    func showDropDown(sender: FloatingTextField) {
        dropDown.anchorView = sender

        var provincesData: [String] = []
        var agenciesData: [String] = []

        switch sender {
        case provinceField:
            NetworkManager.shared.fetchProvinces { [weak self] result in
                switch result {
                case let .success(provinces):
                    provinces.response.forEach { province in
                        provincesData.append(province.name)
                    }

                    self?.dropDown.dataSource = provincesData

                    DispatchQueue.main.async {
                        self?.dropDown.show()
                    }

                    self?.dropDown.selectionAction = { index, item in
                        self?.provinceField.text = item
                        self?.provinceField.updatePlaceholderFrame(true)
                        self?.provinceID = index + 1
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        case pharmacyField:
            NetworkManager.shared.fetchAgency(provinceID: provinceID) { [weak self] result in
                switch result {
                case let .success(agencies):
                    var agencyIDs: [Int] = []
                    agencies.response.forEach { agency in
                        agenciesData.append(agency.name)
                        agencyIDs.append(agency.id)
                    }
                    self?.dropDown.dataSource = agenciesData

                    DispatchQueue.main.async {
                        self?.dropDown.show()
                    }

                    self?.dropDown.selectionAction = { index, item in
                        self?.pharmacyField.text = item
                        self?.pharmacyField.updatePlaceholderFrame(true)
                        self?.agencyID = agencyIDs[index]
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        default:
            break
        }
    }
}

extension CustomerRegisterVC: FloatingTextFieldDelegate {
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
        case provinceField, pharmacyField:
            textField.endEditing(true)

            showDropDown(sender: textField as! FloatingTextField)
        case avatarField:
            textField.endEditing(true)

            DispatchQueue.main.async {
//                self.showImagePickerOptions()
                self.showImagePickerPopup()
            }
        case passwordField:
            isPasswordVisible.toggle()

            textField.isSecureTextEntry = !isPasswordVisible

            guard let image = isPasswordVisible ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill") else { return }
            passwordField.rightViewSetup(rightViewImage: image)
        default:
            break
        }
    }

    func floatingTextFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let province = provinceField.text, textField == pharmacyField, province.isEmpty {
            textField.isUserInteractionEnabled = false
            return false
        }

        return true
    }

    func floatingTextFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case provinceField, pharmacyField:
            textField.endEditing(true)

            showDropDown(sender: textField as! FloatingTextField)
        case avatarField:
            textField.endEditing(true)

            DispatchQueue.main.async {
//                self.showImagePickerOptions()
                self.showImagePickerPopup()
            }
        default:
            break
        }
    }
}

extension CustomerRegisterVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatarImage.image = pickedImage

            let imageAspectRatio = pickedImage.size.width / pickedImage.size.height

            NSLayoutConstraint.deactivate(avatarImage.constraints)

            NSLayoutConstraint.activate([
                avatarImage.widthAnchor.constraint(equalTo: avatarImage.heightAnchor, multiplier: imageAspectRatio),
            ])

            avatarImage.layer.cornerRadius = 10
        }
    }
}
