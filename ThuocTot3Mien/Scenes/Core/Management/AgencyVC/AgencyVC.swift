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
    var categoryName: String = ""
    var categoryKey: String = ""
    var bestSellerOnClick: (() -> Void)?
    var discountOnClick: (() -> Void)?
    var allProductsOnClick: (() -> Void)?
    
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
        if let pharmacyName = UserDefaults.standard.string(forKey: "pharmacyName") {
            bannerView.titleLabel.text = pharmacyName
        }
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
        bestSellerOnClick?()
    }
    
    @IBAction func discountTapped() {
        discountOnClick?()
    }
    
    @IBAction func allProductTapped() {
        allProductsOnClick?()
    }

}
