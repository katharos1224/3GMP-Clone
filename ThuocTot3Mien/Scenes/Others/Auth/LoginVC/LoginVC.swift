//
//  LoginVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import Combine
import UIKit

final class LoginVC: BaseViewController {
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var passwordField: FloatingTextField!
    @IBOutlet var phoneWarningLabel: UILabel!
    @IBOutlet var passwordWarningLabel: UILabel!
    @IBOutlet var userImage: UIImageView!

    private var cancellables: Set<AnyCancellable> = []

    let viewModel = AuthViewModel()

    var isPasswordVisible = false
    var isCustomer: Bool = false

    var signInOnClick: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }

    override func setupUI() {
        userImage.image = isCustomer ? UIImage(named: "ic_customer") : UIImage(named: "ic_pharmacy")

        let textFields: [FloatingTextField] = [phoneField, passwordField]

        textFields.forEach { textField in
            guard let text = textField.text, text.isEmpty else {
                DispatchQueue.main.async {
                    textField.updatePlaceholderFrame(true)
                }
                return
            }
        }
        AppCoordinator.shared.completionPublisher
            .sink { [weak self] in
                DispatchQueue.main.async {
                    self?.popToRoot()
                }
            }
            .store(in: &cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()

        userImage.layer.cornerRadius = userImage.frame.size.height / 2
    }

    @IBAction func dismiss() {
        popWithCrossDissolve()
    }

    @IBAction func forgotPasswordTapped() {
        let vc = ForgotPasswordVC()
        pushWithCrossDissolve(vc)
    }

    @IBAction func registerTapped() {
        let vc = isCustomer ? CustomerRegisterVC() : PharmacyRegisterVC()
        pushWithCrossDissolve(vc)
    }

    @IBAction func signInTapped() {
        phoneField.resignFirstResponder()
        passwordField.resignFirstResponder()

        let fields: [FloatingTextField] = [phoneField, passwordField]
        let labels = [phoneWarningLabel, passwordWarningLabel]

        guard let phone = phoneField.text, phone.count == 10, !phone.isEmpty,
              let password = passwordField.text, password.count > 0, !password.isEmpty
        else {
            for index in fields.indices {
                let field = fields[index]
                let label = labels[index]

                label?.textColor = .systemRed
                field.bottomLineColor = .systemRed
                field.updatedBottomLineColor(true)

                if !field.text!.isEmpty {
                    label?.textColor = .clear
                    field.bottomLineColor = .systemGreen
                    field.updatedBottomLineColor(true)

                    if field == phoneField, field.text!.count < 10 {
                        field.bottomLineColor = .systemRed
                        field.updatedBottomLineColor(true)

                        showAlert(title: "Oops", message: "Số điện thoại phải có 10 chữ số!")
                    }
                }
            }

            return
        }

        for index in fields.indices {
            let field = fields[index]
            let label = labels[index]

            label!.textColor = .clear
            field.bottomLineColor = .systemGreen
            field.updatedBottomLineColor(true)
        }

        setupLoginObserver(username: phone, password: password)
    }

    private func setupLoginObserver(username: String, password: String) {
        viewModel.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            .store(in: &cancellables)
    }

    private func setupViewModel() {
        viewModel.isCustomer = isCustomer
        viewModel.isPasswordVisible = isPasswordVisible

        viewModel.updateUI = { [weak self] in
            DispatchQueue.main.async {
                let vc = TabBarVC()
                self?.show(vc)
            }
        }

        viewModel.showResponseMessage = { [weak self] responseMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Đăng nhập không thành công", message: responseMessage)
            }
        }

        viewModel.showLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.showLoadingIndicator() : self?.hideLoadingIndicator()
            }
        }
    }
}

extension LoginVC: FloatingTextFieldDelegate {
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
        if textField == passwordField {
            viewModel.togglePasswordVisibility()
            textField.isSecureTextEntry = !viewModel.isPasswordVisible

            guard let image = viewModel.isPasswordVisible ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill") else { return }
            passwordField.rightViewSetup(rightViewImage: image)
        }
    }
}
