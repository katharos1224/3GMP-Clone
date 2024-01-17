//
//  CartVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 10/12/2023.
//

import UIKit
import FFPopup

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
    
    let changeAmountContentView: ChangeAmountView = {
        let width = (4 / 5) * UIScreen.main.bounds.size.width
        let height = width * (3 / 5)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = ChangeAmountView(frame: frame)
        return view
    }()

    var changeAmountPopupView = FFPopup()

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
                
                self?.totalNumber = 0
                self?.totalPrice = 0
                
                self?.cartProducts = response.products.data
                self?.tempCartProducts = response.products.data
                self?.reductionRate = "\(response.tiLeGiam)"

                let haveProducts = self?.cartProducts.count != 0
                self?.isAllChecked = haveProducts ? true : false

                self?.cartProducts.forEach { product in
                    let id = product.id
                    let number = product.soLuong
                    let price = (product.khuyenMai != 0 && product.khuyenMai != nil) ? Int(round(product.discountPrice)) : product.donGia
                    
                    self?.totalNumber += number
                    self?.totalPrice += price * number
                    
                    let checkmarkTuple = (id, true)
                    self?.checkmarkStatus.append(checkmarkTuple)
                }

                DispatchQueue.main.async {
                    self?.checkmarkAllButton.isEnabled = haveProducts ? true : false
                    self?.totalNumberLabel.text = String(self!.totalNumber)
                    self?.totalPriceLabel.text = String(self!.totalPrice.formattedWithSeparator()) + " VNĐ"
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

        let cellWidth = Constants.WIDTH_SCREEN
        let cellHeight = (5 / 9) * cellWidth
        let spacing = Constants.SPACING_ZERO
        let padding = Constants.PADDING_ZERO

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
    
    func showChangeAmountPopup() {
        changeAmountPopupView = FFPopup(contentView: changeAmountContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        
        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        changeAmountPopupView.show(layout: layout)
    }

    func dismissPopup() {
        changeAmountPopupView.dismiss(animated: true)
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
                totalPrice += product.discountPrice == 0 ? product.donGia * product.soLuong : Int(round(product.discountPrice)) * product.soLuong
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
