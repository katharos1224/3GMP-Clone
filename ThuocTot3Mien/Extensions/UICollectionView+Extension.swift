//
//  UICollectionView+Extension.swift
//  MenuVNC
//
//  Created by Katharos on 11/11/2023.
//

import UIKit

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_: T.Type) {
        let identifier = String(describing: T.self)
        register(T.self, forCellWithReuseIdentifier: identifier)
    }

    func registerCellFromNib<T: UICollectionViewCell>(_: T.Type, nibName: String) {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: identifier)
    }

    func registerHeaderFromNib<T: UICollectionReusableView>(_: T.Type, nibName: String) {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }

    func registerFooterFromNib<T: UICollectionReusableView>(_: T.Type, nibName: String) {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
}
