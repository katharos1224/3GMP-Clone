//
//  AgencyVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 22/01/2024.
//

import UIKit

final class AgencyVC: BaseViewController {
    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var agencyCategory: [AgencyCategory] = []
    
    let cellWidth = Constants.WIDTH_SCREEN - 32
    let cellHeight = (1 / 9) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING

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
    
    override func setupUI() {
        super.setupUI()
        
        bannerView.titleLabel.isHidden = false
        bannerView.stackBar.isHidden = true
        bannerView.titleLabel.text = "Nha thuoc abcxyz"
        bannerView.dismiss = {
            self.popWithCrossDissolve()
        }
        
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
    }
    
    override func viewWillAppear(_: Bool) {
        self.hideLoadingIndicator()
    }
    
    func setupData() {
        NetworkManager.shared.fetchAgencyCategory { [weak self] result in
            switch result {
            case .success(let data):
                guard let response = data.response else {
                    print(data.message)
                    return
                }
                
                self?.agencyCategory = response
                print(response)
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
//                    self?.hideLoadingIndicator()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func bestSellerTapped() {
    }
    
    @IBAction func discountTapped() {
    }
    
    @IBAction func allProductTapped() {
    }
    

}

extension AgencyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return agencyCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

            NetworkManager.shared.fetchAgencyProducts(page: nil, category: key, search: nil, hoatChat: indexPath.section == 0 ? id : nil, nhomThuoc: indexPath.section == 1 ? id : nil, nhaSanXuat: indexPath.section == 2 ? id : nil) { result in
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
//                let vc = CategoryDetailVC()
//                vc.type = data.key
//                vc.titleName = data.name
//                pushWithCrossDissolve(vc)
            }

            return headerView
        }

        return UICollectionReusableView()
    }
}
