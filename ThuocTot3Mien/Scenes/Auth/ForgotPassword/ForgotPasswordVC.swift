//
//  ForgotPasswordVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import UIKit

final class ForgotPasswordVC: BaseViewController {
    @IBOutlet var phoneField: FloatingTextField!
    @IBOutlet var phoneWarningLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_: Bool) {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
        }
    }

    @IBAction func dismiss() {
        popWithCrossDissolve()
    }

    @IBAction func sendButtonTapped() {
        phoneField.resignFirstResponder()

        guard let phone = phoneField.text, phone.count == 10, phoneField.text != "" else {
            let isPhoneEmpty = phoneField.text == "" || phoneField.text == nil
            let isPhoneInvalid = phoneField.text!.count > 0 && phoneField.text!.count < 10 && !isPhoneEmpty

            phoneWarningLabel.textColor = isPhoneEmpty ? .systemRed : .clear
            phoneField.bottomLineColor = isPhoneEmpty ? .systemRed : .systemGreen
            phoneField.updatedBottomLineColor(true)

            if isPhoneInvalid {
                phoneWarningLabel.textColor = .clear
                phoneField.bottomLineColor = .systemRed
                phoneField.updatedBottomLineColor(true)
                showAlert(title: "Oops!", message: "Số điện thoại phải có 10 chữ số!")
            }

            return
        }

        phoneWarningLabel.textColor = .clear
        phoneField.bottomLineColor = .systemGreen
        phoneField.updatedBottomLineColor(true)

        // Start Reset Passwords in here
    }
}

extension ForgotPasswordVC: FloatingTextFieldDelegate {
    func floatingTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        return newText.count <= 10
    }
}
