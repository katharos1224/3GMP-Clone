//
//  AgencyVC+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import UIKit

extension AgencyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return agencyCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            bestSellerOnClick = {
                NetworkManager.shared.fetchAgencyProducts(page: nil, category: "ban_chay", search: nil, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil) { [weak self] result in
                    switch result {
                    case let .success(data):
                        guard let response = data.response else {
                            print(data.message)
                            return
                        }
                        let vc = ProductsVC()
                        vc.titleLabel = "Bán chạy"
                        vc.agencyProducts = response.data
                        vc.lastPage = response.lastPage
                        vc.cellHeight = (17 / 20) * Constants.WIDTH_SCREEN

                        DispatchQueue.main.async {
                            self?.pushWithCrossDissolve(vc)
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        case 1:
            discountOnClick = {
                NetworkManager.shared.fetchAgencyProducts(page: nil, category: "khuyen_mai", search: nil, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil) { [weak self] result in
                    switch result {
                    case let .success(data):
                        guard let response = data.response else {
                            print(data.message)
                            return
                        }
                        let vc = ProductsVC()
                        vc.titleLabel = "Khuyến mãi"
                        vc.agencyProducts = response.data
                        vc.lastPage = response.lastPage
                        vc.cellHeight = (17 / 20) * Constants.WIDTH_SCREEN

                        DispatchQueue.main.async {
                            self?.pushWithCrossDissolve(vc)
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            allProductsOnClick = {
                NetworkManager.shared.fetchAgencyProducts(page: nil, category: "all", search: nil, hoatChat: nil, nhomThuoc: nil, nhaSanXuat: nil) { [weak self] result in
                    switch result {
                    case let .success(data):
                        guard let response = data.response else {
                            print(data.message)
                            return
                        }
                        let vc = ProductsVC()
                        vc.titleLabel = "Tất cả sản phẩm"
                        vc.agencyProducts = response.data
                        vc.lastPage = response.lastPage
                        vc.cellHeight = (17 / 20) * Constants.WIDTH_SCREEN

                        DispatchQueue.main.async {
                            self?.pushWithCrossDissolve(vc)
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        return agencyCategory[section].category.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCVCell.identifier, for: indexPath) as! CategoryCVCell
        let category = agencyCategory[indexPath.section].category[indexPath.row]
        cell.configure(name: category.name)

        cell.cellTapOnClick = { [weak self] in
            let id = category.value
            let name = category.name
            let key = self?.agencyCategory[indexPath.section].key
            let vc = ProductsVC()
            vc.section = indexPath.section
            vc.id = id
            vc.titleLabel = name
            vc.cellHeight = (17 / 20) * Constants.WIDTH_SCREEN

            NetworkManager.shared.fetchAgencyProducts(page: nil, category: key, search: nil, hoatChat: indexPath.section == 0 ? id : nil, nhomThuoc: indexPath.section == 1 ? id : nil, nhaSanXuat: indexPath.section == 2 ? id : nil) { [weak self] result in
                switch result {
                case let .success(data):
                    guard let response = data.response else {
                        print(data.message)
                        return
                    }
                    vc.agencyProducts = response.data
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

            let data = agencyCategory[indexPath.section]

            headerView.configure(image: data.icon, name: data.name)
            headerView.icon.image = UIImage(systemName: "gearshape.fill")

            headerView.onClick = { [self] in
                let vc = AgencyCategoryTypeVC()
                vc.type = data.key
                vc.titleName = data.name
                pushWithCrossDissolve(vc)
            }

            return headerView
        }

        return UICollectionReusableView()
    }
}
