//
//  InfoVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import UIKit
import Combine

struct MenuItem {
    let title: String
    let imageName: String
}

final class InfoVC: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellWidth = UIScreen.main.bounds.width - 32
    let cellHeight = (1 / 13) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 16.0
    
    let menuItems = [
        MenuItem(title: "Thông tin tài khoản", imageName: "person.fill"),
        MenuItem(title: "Quản lý gian hàng", imageName: "info.circle.fill"),
        MenuItem(title: "Liên hệ", imageName: "envelope.fill"),
        MenuItem(title: "Tin tức", imageName: "newspaper.fill"),
        MenuItem(title: "Giới thiệu", imageName: "info.circle.fill"),
        MenuItem(title: "Điều khoản sử dụng", imageName: "doc.text"),
        MenuItem(title: "Chính sách bảo mật", imageName: "shield.fill"),
        MenuItem(title: "Hướng dẫn mua hàng", imageName: "cart.fill"),
        MenuItem(title: "Chính sách thanh toán", imageName: "creditcard.fill"),
        MenuItem(title: "Chính sách giao hàng", imageName: "shippingbox.fill"),
        MenuItem(title: "Chính sách đổi trả", imageName: "arrow.triangle.2.circlepath.circle.fill"),
        MenuItem(title: "Chính sách bảo hành", imageName: "wrench.fill"),
        MenuItem(title: "Chính sách kiểm hàng", imageName: "checkmark.seal.fill"),
        MenuItem(title: "Nghĩa vụ của người bán và khách hàng trong mỗi giao dịch", imageName: "person.2.fill")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideLoadingIndicator()
    }

    override func viewWillAppear(_: Bool) {
    }
    
    override func setupUI() {
        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(ManagementCell.self, nibName: ManagementCell.identifier)
        collectionView.backgroundColor = .white
    }

    @IBAction func signoutTapped() {
        KeychainService.deleteToken()
        DispatchQueue.main.async {
            self.hide()
        }
    }
}

extension InfoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManagementCell.identifier, for: indexPath) as! ManagementCell
        
        let menuItem = menuItems[indexPath.item]
        cell.configure(item: menuItem)
        
        cell.cellTapOnClick = { [weak self] in
            DispatchQueue.main.async { [self] in
                if indexPath.item > 3 {
                    let url = URL(string: "http://18.138.176.213/system/general_information/\(indexPath.item - 3)")
                    let paymentWebView = WebViewVC(url: url!)
                    paymentWebView.navTitle = menuItem.title
    //                self?.navigationController?.setNavigationBarHidden(false, animated: false)
                    self?.pushWithCrossDissolve(paymentWebView)
                } else {
                    switch indexPath.item {
                    case 0:
                        print(indexPath.item)
                        // Thong tin tai khoan
                    case 1:
                        print(indexPath.item)
                        // Quan ly gian hang
                    case 2:
                        NetworkManager.shared.fetchContact { [weak self] result in
                            switch result {
                            case .success(let data):
                                let vc = ContactVC()
                                vc.contacts = data.response
                                DispatchQueue.main.async {
                                    self?.pushWithCrossDissolve(vc)
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    default:
                        print(indexPath.item)
                        // Tin tuc
                    }
                }
            }
        }
        return cell
    }
    
    
}
