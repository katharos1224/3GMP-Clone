//
//  ContactVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/01/2024.
//

import UIKit

final class ContactVC: BaseViewController {
    @IBOutlet var collectionView: UICollectionView!

    let cellWidth = UIScreen.main.bounds.width - 32
    let cellHeight = (1 / 7) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 16.0

    var contacts: [ContactMethod] = []

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

        NetworkManager.shared.fetchContact { [weak self] result in
            switch result {
            case let .success(data):
                self?.contacts = data.response
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
        collectionView.registerCellFromNib(ContactCell.self, nibName: ContactCell.identifier)
        collectionView.backgroundColor = .white
    }

    @IBAction func dismissTapped(_: Any) {
        popWithCrossDissolve()
    }
}

extension ContactVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return contacts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell

        let contactItem = contacts[indexPath.item]
        cell.configure(item: contactItem)

        cell.cellTapOnClick = { [weak self] in
            if let url = URL(string: contactItem.value),
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL: \(contactItem.value)")
            }
        }

        return cell
    }
}
