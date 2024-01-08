//
//  CustomButton.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 30/11/2023.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    // MARK: - Inspectable Properties

    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOffset: CGSize = .init(width: 1, height: 2) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.25 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 5.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var backgroundColorHighlighted: UIColor?

    // MARK: - Designable Properties

    @IBInspectable var normalBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(normalBackgroundColor, forState: .normal)
        }
    }

    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(highlightedBackgroundColor, forState: .highlighted)
        }
    }

    @IBInspectable var normalTitleColor: UIColor? {
        didSet {
            setTitleColor(normalTitleColor, for: .normal)
        }
    }

    @IBInspectable var highlightedTitleColor: UIColor? {
        didSet {
            setTitleColor(highlightedTitleColor, for: .highlighted)
        }
    }

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = highlightedBackgroundColor
            } else {
                backgroundColor = normalBackgroundColor
            }
        }
    }

    // MARK: - Private Methods

    private func setupView() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = true

        setBackgroundColor(normalBackgroundColor, forState: .normal)
        setBackgroundColor(highlightedBackgroundColor, forState: .highlighted)
        setTitleColor(normalTitleColor, for: .normal)
        setTitleColor(highlightedTitleColor, for: .highlighted)
    }

    private func setBackgroundColor(_ color: UIColor?, forState state: UIControl.State) {
        guard let color = color else { return }
        setBackgroundImage(image(withColor: color), for: state)
    }

    private func image(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
