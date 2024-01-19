//
//  HomeVC+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 16/01/2024.
//

import Foundation
import UIKit

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case bannerCollectionView:
            return 1
        default:
            return productsData.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case bannerCollectionView:
            return bannerData.count
        default:
//            productsData[section].data = productsData[section].data.filter { $0.soLuong != 0 }
//            let itemsCount = productsData[section].data.filter { $0.soLuong != 0 }.count
            let itemsCount = productsData[section].data.count

            switch section {
            case productsData.count - 1:
                return itemsCount
            default:
                if itemsCount >= 4 {
                    return 4
                } else {
                    return itemsCount
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case bannerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCVCell.identifier, for: indexPath) as! OnboardingCVCell
            cell.configureBanner(imgURL: bannerData[indexPath.item].value)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCVCell.identifier, for: indexPath) as! ProductCVCell

            let product = productsData[indexPath.section].data[indexPath.item]

            cell.configure(productData: product, memberStatus: memberStatus)

            let view = addCartContentView
            view.amountField.delegate = self

            if cell.addCartButton.isUserInteractionEnabled {
                cell.addToCartOnClick = { [self] in
                    showAddCartPopup()

                    view.tagStack.removeAllArrangedSubviews()
                    view.configure(productData: product)

                    onEndEditing = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu {
                                if amount < minAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                    amount = minAmount
                                    view.amountField.text = "\(minAmount)"
                                }
                            }

                            if let maxAmount = product.soLuongToiDa {
                                if amount > maxAmount {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                    amount = maxAmount
                                    view.amountField.text = "\(maxAmount)"
                                }
                            }

                            if amount < 1 {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0")
                                amount = 1
                                view.amountField.text = "\(1)"
                            }
                        } else {
                            showAlert(title: "Thông báo", message: "Số lượng không hợp lệ.")
                            DispatchQueue.main.async {
                                view.amountField.text = "\(product.soLuongToiThieu ?? 1)"
                            }
                        }
                    }

                    if let minAmount = product.soLuongToiThieu {
                        view.amountField.text = "\(minAmount)"
                    } else {
                        view.amountField.text = "\(1)"
                    }

                    view.minusOnClick = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu {
                                if amount - minAmount > 0 {
                                    amount -= 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                    view.amountField.text = "\(minAmount)"
                                }
                            } else {
                                if amount > 1 {
                                    amount -= 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0.")
                                    view.amountField.text = "\(1)"
                                }
                            }
                        }
                    }

                    view.plusOnClick = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let maxAmount = product.soLuongToiDa {
                                if maxAmount - amount > 0 {
                                    amount += 1
                                    view.amountField.text = "\(amount)"
                                } else {
                                    showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                    view.amountField.text = "\(maxAmount)"
                                }
                            } else {
                                amount += 1
                                view.amountField.text = "\(amount)"
                            }
                        }
                    }

                    view.addCartOnClick = { [self] in
                        if let text = view.amountField.text, var amount = Int(text) {
                            if let minAmount = product.soLuongToiThieu, amount < minAmount {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối thiểu: \(minAmount)")
                                amount = minAmount
                                view.amountField.text = "\(minAmount)"
                            } else if let maxAmount = product.soLuongToiDa, amount > maxAmount {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng tối đa: \(maxAmount)")
                                amount = maxAmount
                                view.amountField.text = "\(maxAmount)"
                            } else if amount < 1 {
                                showAlert(title: "Số lượng không hợp lệ!", message: "Số lượng sản phẩm phải lớn hơn 0")
                                amount = 1
                                view.amountField.text = "\(1)"
                            } else {
                                let id = product.id
                                let number = amount

                                NetworkManager.shared.updateCart(id: id, number: number) { [weak self] result in
                                    switch result {
                                    case let .success(data):
                                        guard let response = data.response else { return }
                                        if let addCartPopupView = self?.addCartPopupView {
                                            self?.dismissPopup(popupView: addCartPopupView)
                                        }

                                        DispatchQueue.main.async {
                                            self?.showSuccessfullyPopup()
                                            self?.cartAmountLabel.text = "\(String(describing: response.totalNumber))"
                                            self?.cartAmountContainerView.isHidden = response.totalNumber > 0 ? false : true
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            if let successfullyPopupView = self?.successfullyPopupView {
                                                self?.dismissPopup(popupView: successfullyPopupView)
                                            }
                                        }
                                    case let .failure(error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        } else {
                            showAlert(title: "Thông báo", message: "Số lượng không hợp lệ.")
                            DispatchQueue.main.async {
                                view.amountField.text = "\(product.soLuongToiThieu ?? 1)"
                            }
                        }
                    }
                }
            }

            cell.cellTapOnClick = {
                print("Product: \(product.tenSanPham) \nSo luong: \(product.soLuong)")
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == self.collectionView {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomepageHeaderCRView.identifier, for: indexPath) as! HomepageHeaderCRView

                headerView.configure(title: productsData[indexPath.section].name)

                headerView.onClick = { [weak self] in
                    let vc = ProductsVC()
                    vc.titleLabel = self?.productsData[indexPath.section].name ?? ""
                    vc.memberStatus = self?.memberStatus ?? 0
                    vc.totalNumber = self?.totalCart ?? 0

                    let category = self?.productsData[indexPath.section].value
                    vc.category = category

                    NetworkManager.shared.fetchProducts(page: 1, category: category, search: nil, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil, hastag: nil) { [weak self] result in
                        switch result {
                        case let .success(data):
                            guard let response = data.response else {
                                return
                            }
                            vc.categoryProducts = response.data
                            vc.lastPage = response.lastPage

                            DispatchQueue.main.async {
                                self?.pushWithCrossDissolve(vc)
                            }
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    }
                }

                return headerView
            }
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.width, height: 70.0)
        } else {
            return CGSize()
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_: UITextField) {
        onEndEditing?()
        view.endEditing(true)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        onEndEditing?()
        view.endEditing(true)
        return true
    }
}
