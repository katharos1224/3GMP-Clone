//
//  CartVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 10/12/2023.
//

import UIKit

final class CartVC: BaseViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var continueView: UIView!
    @IBOutlet var totalNumberLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var checkmarkAllButton: UIBarButtonItem!
    @IBOutlet var continueButton: UIButton!

    @IBOutlet var heightConstraint: NSLayoutConstraint!

    var tempCartProducts: [CartProduct] = []
    var tempChangesSet = [(id: Int, number: Int)]()
    var cartProducts: [CartProduct] = []
    var isAllChecked = Bool()
    var checkmarkStatus = [(id: Int, check: Bool)]()
    var onEndEditing: (() -> Void)?
    var toggleCheckAll: (() -> Void)?

    var totalNumber = 0
    var totalPrice = 0
    var reductionRate: String = ""

    let dispatchGroup = DispatchGroup()

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

    func setupData() {
        NetworkManager.shared.fetchCart { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    self?.cartProducts = []
                    return
                }
                self?.cartProducts = response.products.data
                self?.tempCartProducts = response.products.data
                self?.reductionRate = "\(response.tiLeGiam)"

                let haveProducts = self?.cartProducts.count != 0
                self?.isAllChecked = haveProducts ? true : false

                self?.cartProducts.forEach { product in
                    let id = product.id
                    let number = product.soLuong
                    let checkmarkTuple = (id, true)
                    self?.checkmarkStatus.append(checkmarkTuple)
                }

                DispatchQueue.main.async {
                    self?.checkmarkAllButton.isEnabled = haveProducts ? true : false
                    self?.totalNumberLabel.text = String(response.totalNumber)
                    self?.totalPriceLabel.text = String(response.totalPrice.formattedWithSeparator()) + " VNĐ"
                    self?.checkmarkAllButton.image = UIImage(systemName: self?.isAllChecked ?? true ? "checkmark.square.fill" : "square")
                    self?.continueButton.isUserInteractionEnabled = self?.tempCartProducts.isEmpty ?? true ? false : true
                    self?.continueButton.backgroundColor = self?.tempCartProducts.isEmpty ?? true ? .placeholderText : .systemGreen

                    self?.reloadDataAndAdjustHeight()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func setupUI() {
        let cornerRadius: CGFloat = 20
        let path = UIBezierPath(
            roundedRect: UIScreen.main.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        continueView.layer.mask = maskLayer

        NotificationCenter.default.addObserver(self, selector: #selector(handleTextFieldChange(_:)), name: Notification.Name("TextFieldDidChange"), object: nil)

        let cellWidth = UIScreen.main.bounds.width
        let cellHeight = (1 / 4) * UIScreen.main.bounds.height
        let spacing = 0.0
        let padding = 0.0

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout

        collectionView.registerCellFromNib(AddedProductCVCell.self, nibName: AddedProductCVCell.identifier)
    }

    @objc func handleTextFieldChange(_: Notification) {
        setupData()
    }

    func reloadDataAndAdjustHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        heightConstraint.constant = contentHeight
    }

    func containsID(id: Int) -> Bool {
        return tempChangesSet.contains { $0.id == id }
    }

    func addTempChange(id: Int, number: Int) {
        if !containsID(id: id) {
            tempChangesSet.append((id: id, number: number))
        } else {
            if let index = tempChangesSet.firstIndex(where: { $0.id == id }) {
                tempChangesSet[index] = (id: id, number: number)
            }
        }
    }

    func removeTempChange(id: Int) {
        tempChangesSet.removeAll { $0.id == id }
    }

    @IBAction func dismissTapped(_: Any) {
        saveDataWithDispatchGroup { [self] success in
            if success {
                dispatchGroup.notify(queue: .main) {
                    self.popWithCrossDissolve()
                }
            }
        }
    }

    @IBAction func checkmarkAllTapped() {
        isAllChecked.toggle()

        checkmarkStatus = checkmarkStatus.map { id, _ in
            (id: id, check: isAllChecked)
        }

        if isAllChecked {
            tempCartProducts = cartProducts

            var totalNumber = 0
            var totalPrice = 0

            tempCartProducts.forEach { product in
                totalNumber += product.soLuong
                totalPrice += product.donGia * product.soLuong
            }

            self.totalNumber = totalNumber
            self.totalPrice = totalPrice

            DispatchQueue.main.async {
                self.checkmarkAllButton.image = UIImage(systemName: "checkmark.square.fill")
                self.totalNumberLabel.text = String(self.totalNumber)
                self.totalPriceLabel.text = String(self.totalPrice.formattedWithSeparator()) + " VNĐ"
                self.reloadDataAndAdjustHeight()
                self.continueButton.isUserInteractionEnabled = true
                self.continueButton.backgroundColor = .systemGreen
            }
        } else {
            tempCartProducts.removeAll()

            DispatchQueue.main.async { [self] in
                checkmarkAllButton.image = UIImage(systemName: "square")
                totalNumberLabel.text = ""
                totalPriceLabel.text = ""
                reloadDataAndAdjustHeight()
                continueButton.isUserInteractionEnabled = false
                continueButton.backgroundColor = .placeholderText
            }
        }
    }

    func saveDataWithDispatchGroup(completion: @escaping (Bool) -> Void) {
        for change in tempChangesSet {
            dispatchGroup.enter()

            NetworkManager.shared.updateCart(id: change.id, number: change.number) { [weak self] result in
                switch result {
                case .success:
                    print("Updated \(self!.tempChangesSet)")
                case .failure:
                    completion(false)
                }

                self?.dispatchGroup.leave()
            }
        }

        completion(true)
    }

    @IBAction func continueTapped() {
        let vc = PurchaseVC()
        vc.purchaseProducts = tempCartProducts
        vc.reductionRate = reductionRate
        pushWithCrossDissolve(vc)
    }
}

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
    func textFieldDidEndEditing(_: UITextField) {
        setupData()
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        setupData()
        return true
    }
}
