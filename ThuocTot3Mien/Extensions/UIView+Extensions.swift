//
//  UIView+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 07/12/2023.
//

import UIKit

extension UIView {
    var roundedBottomCorners: Bool {
        get {
            return layer.mask != nil
        }
        set {
            if newValue {
                addRoundedBottomCorners()
            } else {
                removeRoundedBottomCorners()
            }
        }
    }

    private func addRoundedBottomCorners() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }

    private func removeRoundedBottomCorners() {
        layer.mask = nil
    }
}
