//
//  ContactVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/01/2024.
//

import UIKit

class ContactVC: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellWidth = UIScreen.main.bounds.width - 32
    let cellHeight = (1 / 7) * UIScreen.main.bounds.height
    let spacing = 16.0
    let padding = 16.0
    
    var contacts: [ContactMethod] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func dismissTapped(_ sender: Any) {
        popWithCrossDissolve()
    }
}

extension ContactVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        
        let contactItem = contacts[indexPath.item]
        cell.configure(item: contactItem)
        
        cell.cellTapOnClick = { [weak self] in
            if let url = URL(string: contactItem.value),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL: \(contactItem.value)")
            }
        }
        
        return cell
    }
}
