//
//  NewsVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import UIKit

class NewsVC: BaseViewController {
    @IBOutlet var collectionView: UICollectionView!

    let cellWidth = Constants.WIDTH_SCREEN - 32
    let cellHeight = (1 / 5) * Constants.HEIGHT_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING

    var news: [NewsItem] = []
    var currentPage: Int = 0

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

        NetworkManager.shared.fetchNews(page: currentPage) { [weak self] result in
            switch result {
            case let .success(data):
                guard let response = data.response else { return }
                self?.news = response.data
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func setupUI() {
        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.registerCellFromNib(NewsCell.self, nibName: NewsCell.identifier)
        collectionView.backgroundColor = .white
    }

    @IBAction func dismissTapped(_: Any) {
        popWithCrossDissolve()
    }
}

extension NewsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return news.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.identifier, for: indexPath) as! NewsCell

        let newsItem = news[indexPath.item]
        cell.configure(item: newsItem)

        cell.cellTapOnClick = { [weak self] in
            let url = URL(string: newsItem.url)
            let paymentWebView = WebViewVC(url: url!)
            paymentWebView.navTitle = "Tin tức"
            self?.pushWithCrossDissolve(paymentWebView)
        }

        return cell
    }
}
