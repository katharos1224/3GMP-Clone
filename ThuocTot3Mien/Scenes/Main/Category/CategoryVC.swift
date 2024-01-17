//
//  CategoryVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import UIKit

final class CategoryVC: BaseViewController {
    @IBOutlet var bannerView: BannerView!
    @IBOutlet var collectionView: UICollectionView!

    let cellWidth = Constants.WIDTH_SCREEN - 32
    let cellHeight = (1 / 9) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING

    var categoriesData: [CategoryResponseData] = []

    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.headerReferenceSize = CGSize(width: cellWidth, height: cellHeight + 16)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white

        collectionView.registerCellFromNib(CategoryCVCell.self, nibName: CategoryCVCell.identifier)
        collectionView.registerHeaderFromNib(CategoryCRView.self, nibName: CategoryCRView.identifier)

        bannerView.backButton.isHidden = true

        let searchTap = UITapGestureRecognizer(target: self, action: #selector(searchTapped))
        bannerView.textField.addGestureRecognizer(searchTap)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_: Bool) {
        tabBarController?.tabBar.isHidden = false
        showLoadingIndicator()

        NetworkManager.shared.fetchCategory { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }

                self?.categoriesData = response

                DispatchQueue.main.async {
                    self?.bannerView.configure(title: "Danh mục sản phẩm")
                    self?.collectionView.reloadData()
                    self?.hideLoadingIndicator()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    @objc private func searchTapped() {
        let vc = SearchResultVC()
        pushWithCrossDissolve(vc)
    }

    func reloadDataAndAdjustHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
//        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
//        heightConstraint.constant = contentHeight
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return categoriesData.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesData[section].category.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCVCell.identifier, for: indexPath) as! CategoryCVCell
        let category = categoriesData[indexPath.section].category[indexPath.row]
        cell.configure(name: category.name)

        cell.cellTapOnClick = { [weak self] in
            let id = self?.categoriesData[indexPath.section].category[indexPath.row].value
//            let name = self?.categoriesData[indexPath.section].category[indexPath.row].name
            let vc = ProductsVC()
            vc.section = indexPath.section
            vc.id = id ?? 0

            NetworkManager.shared.fetchProducts(page: nil, category: nil, search: nil, hoatChat: indexPath.section == 0 ? id : nil, nhomThuoc: indexPath.section == 1 ? id : nil, nhaSanXuat: indexPath.section == 2 ? id : nil, hastag: nil) { result in
                switch result {
                case let .success(data):
                    guard let response = data.response else {
                        print(result)
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

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryCRView.identifier, for: indexPath) as! CategoryCRView

            let data = categoriesData[indexPath.section]

            headerView.configure(image: data.icon, name: data.name)

            headerView.onClick = { [self] in
                let vc = CategoryDetailVC()
                vc.type = data.key
                vc.titleName = data.name
                pushWithCrossDissolve(vc)
            }

            return headerView
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        print("Fakkkk")
    }
}
