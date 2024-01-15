//
//  CustomView.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 30/11/2023.
//

import Foundation

import UIKit

@IBDesignable
class CustomView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.3 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowOffset: CGSize = .init(width: 3.0, height: 3.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 3.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var backgroundColorAlpha: CGFloat = 1.0 {
        didSet {
            backgroundColor = backgroundColor?.withAlphaComponent(backgroundColorAlpha)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        backgroundColor = .white
    }
}
