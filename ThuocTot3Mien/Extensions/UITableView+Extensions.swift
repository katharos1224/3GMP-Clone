//
//  UITableView+Extensions.swift
//  MenuVNC
//
//  Created by Katharos on 11/11/2023.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_: T.Type) {
        let identifier = String(describing: T.self)
        register(T.self, forCellReuseIdentifier: identifier)
    }

    func registerCellFromNib<T: UITableViewCell>(_: T.Type, nibName: String) {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: identifier)
    }

    func registerHeaderFooterViewFromNib<T: UITableViewHeaderFooterView>(_: T.Type, nibName: String) {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}
