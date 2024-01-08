//
//  PaymentHistoryVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/01/2024.
//

import UIKit

class PaymentHistoryVC: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var historyData: [OrderHistoryItem] = []
    var subControllers: [UIViewController] = []
    
    var currentPage: Int = 1
    var lastPage: Int?
    var isLoadingMore = false
    
    let cellWidth = UIScreen.main.bounds.width - 32
    let cellHeight = (1 / 8) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 0.0
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCollectionView()
    }
    
    override func viewWillAppear(_: Bool) {
        tabBarController?.tabBar.isHidden = false
        showLoadingIndicator()
        setupData()
    }
    
    func setupCollectionView() {
        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(HistoryCVCell.self, nibName: HistoryCVCell.identifier)
        collectionView.backgroundColor = .white
    }
    
    private func setupData() {
        NetworkManager.shared.fetchHistory(page: currentPage) { [weak self] result in
            switch result {
            case .success(let data):
                guard let response = data.response, let historyData = response.data else { return }
                self?.historyData = historyData
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.hideLoadingIndicator()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension PaymentHistoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCVCell.identifier, for: indexPath) as! HistoryCVCell
        
        let order = historyData[indexPath.item]
        cell.configure(order: order)
        
        cell.cellTapOnClick = { [weak self] in
            let vc = PaymentDetailVC()
            vc.paymentID = order.id!
            
            self?.pushWithCrossDissolve(vc)
        }
        
        return cell
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
        
        NetworkManager.shared.fetchHistory(page: currentPage) { [weak self] result in
            switch result {
            case .success(let data):
                guard let response = data.response, let historyData = response.data else {
                    self?.isLoadingMore = false
                    return
                }
                
                self?.historyData += historyData

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.isLoadingMore = false
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
