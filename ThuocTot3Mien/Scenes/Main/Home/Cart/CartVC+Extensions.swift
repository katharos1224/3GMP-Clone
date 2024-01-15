//
//  CartVC+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 16/01/2024.
//

import Foundation
import UIKit

extension CartVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return cartProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddedProductCVCell.identifier, for: indexPath) as! AddedProductCVCell

        let id = cartProducts[indexPath.item].id
        if let index = checkmarkStatus.firstIndex(where: { $0.id == id }) {
            cell.isChecked = checkmarkStatus[index].check
        }
        cell.configure(productData: cartProducts[indexPath.item])
        cell.amountField.delegate = self

        cell.checkOnClick = { [self] in
            if let indexToToggle = checkmarkStatus.firstIndex(where: { $0.id == id }) {
                checkmarkStatus[indexToToggle].check.toggle()
                cell.isChecked = checkmarkStatus[indexToToggle].check
            }

            cell.configure(productData: cartProducts[indexPath.item])

            isAllChecked = checkmarkStatus.filter { $0.check == false }.count == 0
            checkmarkAllButton.image = UIImage(systemName: isAllChecked ? "checkmark.square.fill" : "square")

            let product = cartProducts[indexPath.item]

            cell.isChecked ? tempCartProducts.append(product) : tempCartProducts.removeAll { $0.id == product.id }

            updateCartInfo()

            DispatchQueue.main.async { [self] in
                continueButton.isUserInteractionEnabled = tempCartProducts.isEmpty ? false : true
                continueButton.backgroundColor = tempCartProducts.isEmpty ? .placeholderText : .systemGreen
            }
        }

        cell.deleteOnClick = { [self] in
            var actions: [UIAlertAction] = []
            let deleteAction = UIAlertAction(title: "Xoá", style: .default) { [self] _ in
                if let indexToRemove = checkmarkStatus.firstIndex(where: { $0.id == cartProducts[indexPath.item].id }) {
                    checkmarkStatus.remove(at: indexToRemove)

                    if tempCartProducts.contains(where: { $0.id == cartProducts[indexPath.item].id }) {
                        tempCartProducts.removeAll { $0.id == cartProducts[indexPath.item].id }
                    }
                }

                removeTempChange(id: cartProducts[indexPath.item].id)
                print(tempChangesSet)

                NetworkManager.shared.updateCart(id: cartProducts[indexPath.item].id, number: 0) { [weak self] _ in
                    NetworkManager.shared.fetchCart { [weak self] result in
                        switch result {
                        case let .success(data):
                            guard let response = data.response else {
                                self?.cartProducts = []
                                DispatchQueue.main.async {
                                    self?.totalNumberLabel.text = ""
                                    self?.totalPriceLabel.text = ""
                                    self?.checkmarkAllButton.image = UIImage(systemName: "square")
                                    self?.reloadDataAndAdjustHeight()
                                }
                                return
                            }

                            self?.cartProducts = response.products.data

                            self?.isAllChecked = self?.checkmarkStatus.filter { $0.check == false }.count == 0
                            self?.checkmarkAllButton.image = UIImage(systemName: self?.isAllChecked ?? true ? "checkmark.square.fill" : "square")

                            DispatchQueue.main.async {
                                if self?.cartProducts.count == 0 {
                                    self?.checkmarkAllButton.image = UIImage(systemName: "square")
                                    self?.totalNumberLabel.text = ""
                                    self?.totalPriceLabel.text = ""
                                    self?.reloadDataAndAdjustHeight()
                                } else if self?.checkmarkStatus.filter({ $0.check == false }).count == 0 {
                                    self?.checkmarkAllButton.image = UIImage(systemName: "checkmark.square.fill")
                                    self?.totalNumberLabel.text = String(response.totalNumber)
                                    self?.totalPriceLabel.text = String(response.totalPrice.formattedWithSeparator()) + " VNĐ"
                                    self?.reloadDataAndAdjustHeight()
                                } else {
                                    var totalNumber = 0
                                    var totalPrice = 0

                                    self?.tempCartProducts.forEach { product in
                                        totalNumber += product.soLuong
                                        totalPrice += product.donGia * product.soLuong
                                    }

                                    DispatchQueue.main.async {
                                        self?.checkmarkAllButton.image = UIImage(systemName: "square")
                                        self?.totalNumberLabel.text = String(totalNumber)
                                        self?.totalPriceLabel.text = String(totalPrice.formattedWithSeparator()) + " VNĐ"
                                        self?.reloadDataAndAdjustHeight()
                                    }

                                    self?.totalNumber = totalNumber
                                    self?.totalPrice = totalPrice
                                }
                            }
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    }
                }

                DispatchQueue.main.async { [self] in
                    continueButton.isUserInteractionEnabled = tempCartProducts.isEmpty ? false : true
                    continueButton.backgroundColor = tempCartProducts.isEmpty ? .placeholderText : .systemGreen
                }
            }
            actions.append(deleteAction)
            let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel)
            actions.append(cancelAction)

            showAlert(title: "Xoá sản phẩm", message: "\(cartProducts[indexPath.item].tenSanPham)", actions: actions)
        }

        cell.minusOnClick = { [self] in
            view.endEditing(true)

            let product = cartProducts[indexPath.item]

            if let text = cell.amountField.text, var amount = Int(text) {
                if let minAmount = product.soLuongToiThieu {
                    if amount - minAmount > 0 {
                        amount -= 1
                        let number = (amount < minAmount) ? minAmount : amount
                        cell.amountField.text = "\(number)"

                        let id = cartProducts[indexPath.item].id
                        // them vao mang tam sau khi press minus
                        addTempChange(id: id, number: number)
                        cartProducts[indexPath.item].soLuong = number
                        print(tempChangesSet)

                        updateCartInfo()
                    } else {
                        showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                        cell.amountField.text = "\(minAmount)"

                        updateCartInfo()
                    }
                } else {
                    if amount > 0 {
                        amount -= 1

                        if product.soLuongToiThieu != nil && amount + 1 == product.soLuongToiThieu || amount == 0 {
                            var actions: [UIAlertAction] = []

                            let deleteAction = UIAlertAction(title: "Xoá", style: .default) { [self] _ in
                                if let indexToRemove = checkmarkStatus.firstIndex(where: { $0.id == cartProducts[indexPath.item].id }) {
                                    checkmarkStatus.remove(at: indexToRemove)

                                    if tempCartProducts.contains(where: { $0.id == cartProducts[indexPath.item].id }) {
                                        tempCartProducts.removeAll { $0.id == cartProducts[indexPath.item].id }
                                    }
                                }

                                // them vao mang tam sau khi press minus
//                                addTempChange(id: cartProducts[indexPath.item].id, number: 0)
                                removeTempChange(id: cartProducts[indexPath.item].id)
                                print(tempChangesSet)

                                NetworkManager.shared.updateCart(id: cartProducts[indexPath.item].id, number: 0) { [weak self] _ in
                                    NetworkManager.shared.fetchCart { [weak self] result in
                                        switch result {
                                        case let .success(data):
                                            guard let response = data.response else {
                                                self?.cartProducts = []
                                                DispatchQueue.main.async { [self] in
                                                    self?.totalNumberLabel.text = ""
                                                    self?.totalPriceLabel.text = ""
                                                    self?.checkmarkAllButton.image = UIImage(systemName: "square")
                                                    self?.reloadDataAndAdjustHeight()
                                                }
                                                return
                                            }

                                            self?.cartProducts = response.products.data

                                            self?.isAllChecked = self?.checkmarkStatus.filter { $0.check == false }.count == 0
                                            self?.checkmarkAllButton.image = UIImage(systemName: self!.isAllChecked ? "checkmark.square.fill" : "square")

                                            DispatchQueue.main.async { [self] in
                                                if self!.cartProducts.isEmpty {
                                                    self?.checkmarkAllButton.image = UIImage(systemName: "square")
                                                    self?.totalNumberLabel.text = ""
                                                    self?.totalPriceLabel.text = ""
                                                    self?.reloadDataAndAdjustHeight()
                                                } else if self?.checkmarkStatus.filter({ $0.check == false }).count == 0 {
                                                    self?.checkmarkAllButton.image = UIImage(systemName: "checkmark.square.fill")
                                                    self?.totalNumberLabel.text = String(response.totalNumber)
                                                    self?.totalPriceLabel.text = String(response.totalPrice.formattedWithSeparator()) + " VNĐ"
                                                    self?.reloadDataAndAdjustHeight()
                                                } else {
                                                    self?.updateCartInfo()
                                                }
                                            }
                                        case let .failure(error):
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                            actions.append(deleteAction)

                            let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel) { _ in
                            }
                            actions.append(cancelAction)

                            showAlert(title: "Xoá sản phẩm", message: "\(cartProducts[indexPath.item].tenSanPham)", actions: actions)
                        } else {
                            cell.amountField.text = "\(amount)"

                            // them vao mang tam sau khi press minus
                            addTempChange(id: cartProducts[indexPath.item].id, number: amount)
                            cartProducts[indexPath.item].soLuong = amount
                            print(tempChangesSet)

                            updateCartInfo()
                        }
                    }
                }
            }
        }

        cell.plusOnClick = { [self] in
            view.endEditing(true)
            let product = cartProducts[indexPath.item]

            // need to get actual total amount from homepage, not this cart total amount...
//            let totalAmount = product.soLuong

            if let text = cell.amountField.text, var amount = Int(text) {
                if let maxAmount = product.soLuongToiDa {
                    if maxAmount - amount > 0 {
                        amount += 1
                        cell.amountField.text = "\(amount)"

                        let id = cartProducts[indexPath.item].id
                        // them vao mang tam sau khi press plus
                        addTempChange(id: id, number: amount)
                        cartProducts[indexPath.item].soLuong = amount
                        print(tempChangesSet)

                        updateCartInfo()
                    }
                } else {
                    amount += 1
                    cell.amountField.text = "\(amount)"

                    // them vao mang tam sau khi press plus
                    addTempChange(id: id, number: amount)
                    cartProducts[indexPath.item].soLuong = amount
                    print(tempChangesSet)

                    updateCartInfo()
                }
            }
        }

        return cell
    }

    func updateCartInfo() {
        if tempCartProducts.isEmpty {
            DispatchQueue.main.async { [self] in
                totalNumberLabel.text = ""
                totalPriceLabel.text = ""
                reloadDataAndAdjustHeight()
            }
        } else {
            var totalNumber = 0
            var totalPrice = 0

            cartProducts.forEach { product in
                if tempCartProducts.contains(where: { $0.id == product.id }) {
                    totalNumber += product.soLuong
                    totalPrice += product.donGia * product.soLuong
                }
                for index in tempCartProducts.indices {
                    if tempCartProducts[index].id == product.id {
                        tempCartProducts[index] = product
                    }
                }
            }

            self.totalNumber = totalNumber
            self.totalPrice = totalPrice

            DispatchQueue.main.async { [self] in
                totalNumberLabel.text = String(totalNumber)
                totalPriceLabel.text = String(totalPrice.formattedWithSeparator()) + " VNĐ"

                reloadDataAndAdjustHeight()
            }
        }
    }
}

extension CartVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setupData()
        
        return true
    }
}
