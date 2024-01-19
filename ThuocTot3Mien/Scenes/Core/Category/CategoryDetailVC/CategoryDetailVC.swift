//
//  CategoryDetailVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import Combine
import UIKit

final class CategoryDetailVC: BaseViewController {
    @IBOutlet var bannerView: BannerView!
    @IBOutlet var collectionView: UICollectionView!

    let cellWidth = Constants.WIDTH_SCREEN - 32
    let cellHeight = (3 / 25) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING

    var categories: [Category] = []
    var type: String = ""
    var search: String = ""
    var titleName: String = ""
    var currentPage: Int = 1
    var lastPage: Int?
    var isLoadingMore = false

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

        navigationController?.setNavigationBarHidden(true, animated: false)

        let clearTap = UITapGestureRecognizer(target: self, action: #selector(clearTextTapped))
        bannerView.clearImage.addGestureRecognizer(clearTap)
        bannerView.configure(title: titleName)
        bannerView.textField.placeholder = "Tìm kiếm \(titleName)"
        bannerView.textField.delegate = self
        bannerView.image.isHidden = true
        bannerView.dismiss = {
            self.popWithCrossDissolve()
        }

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(CategoryCVCell.self, nibName: CategoryCVCell.identifier)
        collectionView.registerCell(IndicatorCell.self)

        cancellable = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: bannerView.textField)
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performSearch(query: self?.bannerView.textField.text)
            }
    }

    @objc func clearTextTapped() {
        bannerView.textField.text = ""

        performSearch()

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func performSearch(query: String? = nil) {
        NetworkManager.shared.fetchCategoryType(type: type, page: currentPage, search: query) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    print(data.message)
                    return
                }

                self?.categories = response.data
                self?.lastPage = response.lastPage
                print(response)

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.hideLoadingIndicator()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        performSearch()
    }

    override func viewDidAppear(_: Bool) {
        collectionView.reloadData()
    }
}

extension CategoryDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return categories.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < categories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCVCell.identifier, for: indexPath) as! CategoryCVCell
            let category = categories[indexPath.row]
            cell.configure(name: category.name)

            cell.cellTapOnClick = { [weak self] in
                let id = self?.categories[indexPath.row].value
//                let name = self?.categories[indexPath.row].name
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
        } else {
            let indicatorCell = collectionView.dequeueReusableCell(withReuseIdentifier: IndicatorCell.identifier, for: indexPath) as! IndicatorCell
            
            indicatorCell.indicator.startAnimating()
            
            if currentPage == lastPage {
                DispatchQueue.main.async {
                    indicatorCell.indicator.stopAnimating()
                }
            }
            
            return indicatorCell
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if let lastPage = lastPage, offsetY > contentHeight - height {
            if !isLoadingMore, currentPage < lastPage {
                loadMoreData()
            }
        }
    }

    func loadMoreData() {
        isLoadingMore = true
        currentPage += 1

        NetworkManager.shared.fetchCategoryType(type: type, page: currentPage, search: search) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else {
                    self?.isLoadingMore = false
                    return
                }

                self?.categories += response.data

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.isLoadingMore = false
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CategoryDetailVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        bannerView.clearImage.isHidden = false
        bannerView.searchImage.isHidden = true
    }

    func textFieldDidEndEditing(_: UITextField) {
        bannerView.clearImage.isHidden = true
        bannerView.searchImage.isHidden = false
    }
}
