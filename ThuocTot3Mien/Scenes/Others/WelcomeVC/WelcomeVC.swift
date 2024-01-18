//
//  WelcomeVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 29/11/2023.
//

import UIKit

final class WelcomeVC: BaseViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!

    let numberOfPages: Int = 5
    var currentPage: Int = 0

    let cellWidth = Constants.WIDTH_SCREEN - 32.0
    let cellHeight = (700 / 1080) * Constants.WIDTH_SCREEN - 32.0
    let cellSpacing = 2 * Constants.SPACING
    let padding = Constants.PADDING

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = KeychainService.getToken() {
            let vc = TabBarVC()
            DispatchQueue.main.async {
                self.show(vc)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAutoScroll(for: collectionView, with: 2.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }

    override func setupUI() {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage

        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: 0.0, left: padding, bottom: 0.0, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = cellSpacing
        layout.scrollDirection = .horizontal

        collectionView.collectionViewLayout = layout

        collectionView.registerCellFromNib(OnboardingCVCell.self, nibName: OnboardingCVCell.identifier)
    }

    @IBAction func goToPharmacyTapped(_: UIButton) {
        let vc = LoginVC()
        vc.isCustomer = false
        DispatchQueue.main.async {
            self.pushWithCrossDissolve(vc)
        }
    }

    @IBAction func goToCustomersTapped(_: UIButton) {
        let vc = LoginVC()
        vc.isCustomer = true
        DispatchQueue.main.async {
            self.pushWithCrossDissolve(vc)
        }
    }
}

extension WelcomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        pageControl.numberOfPages = 5
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCVCell.identifier, for: indexPath) as! OnboardingCVCell
        let imageNumber = indexPath.item + 1
        cell.image.frame = CGRect(x: 0.0, y: 0.0, width: cellWidth, height: cellHeight)
        cell.configure(index: imageNumber)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(round(scrollView.contentOffset.x + width / 2.0) / width)
        pageControl.currentPage = currentPage
    }
}
