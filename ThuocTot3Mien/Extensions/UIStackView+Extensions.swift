//
//  UIStackView+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 12/12/2023.
//

import Foundation
import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap { $0.constraints })

        removedSubviews.forEach { $0.removeFromSuperview() }
    }
}
