
import UIKit

let CScreenWidth = UIScreen.main.bounds.size.width
let AnimationDuration = 0.3
let LeftPadding: CGFloat = 10.0

@objc protocol FloatingTextFieldDelegate: AnyObject {
    @objc optional func floatingTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func floatingTextFieldDidChange(_ textField: UITextField)
    @objc optional func floatingTextFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    @objc optional func floatingTextFieldDidBeginEditing(_ textField: UITextField)
    @objc optional func floatingTextFieldDidEndEditing(_ textField: UITextField)
    @objc optional func floatingTextFieldRightViewClick(_ textField: UITextField)
    @objc optional func floatingTextFieldLeftViewClick(_ textField: UITextField)
}

class FloatingTextField: UITextField, UITextFieldDelegate {
    public var txtDelegate: FloatingTextFieldDelegate?

    @IBOutlet
    public var floatingTextFieldDelegate: AnyObject? {
        get { return delegate as AnyObject }
        set { txtDelegate = newValue as? FloatingTextFieldDelegate }
    }

    @IBInspectable var placeHolder: String = ""
    @IBInspectable var placeHolderFont: UIFont?
    @IBInspectable var placeHolderColor: UIColor = .lightGray
    @IBInspectable var placeHolderColorAfterText: UIColor = .lightGray
    @IBInspectable var placeHolderBackgroundColor: UIColor = .white
    @IBInspectable var placeHolderLeftPadding: CGFloat = 10
    @IBInspectable var placeHolderLeftPaddingAfterAnimation: CGFloat = 10

    @IBInspectable var borderColor: UIColor = .black
    @IBInspectable var borderWidth: CGFloat = 0.0
    @IBInspectable var cornerRadius: CGFloat = 1.0

    @IBInspectable var rightViewImage: UIImage = .init()
    @IBInspectable var leftViewImage: UIImage = .init()
    @IBInspectable var allowAnimation: Bool = true
    @IBInspectable var fixedAtTop: Bool = false
    @IBInspectable var roundCorner: Bool = false
    @IBInspectable var showRightView: Bool = false
    @IBInspectable var showLeftView: Bool = false

    var viewBottomLine = UIView()
    @IBInspectable var showBottomLine: Bool = false
    @IBInspectable var bottomLineColor: UIColor = .black
    @IBInspectable var bottomLineSelectedColor: UIColor = .black

    var placeholderFontSize: CGFloat = 17
    var lblPlaceHolder = UILabel()
    var btnRightView = UIButton()
    var btnLeftView = UIButton()

    var padding = UIEdgeInsets(
        top: 0,
        left: LeftPadding,
        bottom: 0,
        right: LeftPadding
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        placeholderFontSize = (font?.pointSize)!

        font = UIFont(
            name: (font?.fontName)!,
            size: round(CScreenWidth * ((font?.pointSize)! / 375))
        )

        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        DispatchQueue.main.async { [self] in
            self.textFieldBorderSetup()

            self.delegate = self
            self.placeHolderSetup()

            // For Right View
            if self.showRightView {
                self.rightViewSetup(rightViewImage: rightViewImage)

                self.padding = UIEdgeInsets(
                    top: 0,
                    left: LeftPadding,
                    bottom: 0,
                    right: self.frame.size.height
                )
            }

            // For Left View
            if self.showLeftView {
                self.leftViewSetup()

                self.padding = UIEdgeInsets(
                    top: 0,
                    left: self.frame.size.height + 5,
                    bottom: 0,
                    right: LeftPadding
                )
            }

            // For Bottom line
            if self.showBottomLine {
                self.bottomLineViewSetup()
            }
        }
    }
}

// MARK: - ----------- ChangeLeftView FrameRect

extension FloatingTextField {
    override func leftViewRect(forBounds _: CGRect) -> CGRect {
        if showLeftView {
            if let rect = leftView?.frame {
                return rect
            }
        }
        return CGRect()
    }
}

// MARK: - ----------- ChangeRightView FrameRect

extension FloatingTextField {
    override func rightViewRect(forBounds _: CGRect) -> CGRect {
        if showRightView {
            if let rect = rightView?.frame {
                return CGRect(origin: CGPoint(x: frame.width - 42, y: 0), size: rect.size)
            }
        }
        return CGRect()
    }
}

// MARK: - --------TextField Inset

extension FloatingTextField {
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

// MARK: - --------Helper Method

extension FloatingTextField {
    private func textFieldBorderSetup() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        // turnery
        if roundCorner {
            layer.cornerRadius = frame.size.height / 2
        } else {
            layer.cornerRadius = cornerRadius
        }
    }

    func updateBottomLineAndPlaceholderFrame() {
        lblPlaceHolder.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: frame.size.width,
            height: lblPlaceHolder.frame.size.height
        )
    }
}

// MARK: - --------PlaceHolder

extension FloatingTextField {
    func placeHolderSetup() {
        lblPlaceHolder.frame = CGRect(
            x: placeHolderXPosstion(false),
            y: frame.origin.y + 5,
            width: frame.size.width,
            height: frame.size.height - 10
        )

        lblPlaceHolder.backgroundColor = placeHolderBackgroundColor
        lblPlaceHolder.textColor = .lightGray
        //        lblPlaceHolder.text = placeHolder.highlightedPlaceholder()
        lblPlaceHolder.attributedText = placeHolder.highlightedPlaceholder()

        lblPlaceHolder.font = UIFont(
            name: (font?.fontName)!,
            size: round(CScreenWidth * (placeholderFontSize / 375))
        )

        lblPlaceHolder.isUserInteractionEnabled = false
        superview?.addSubview(lblPlaceHolder)

        // To fixed placeholder at top
        if fixedAtTop {
            let heightOfLable: CGFloat = CScreenWidth * 16 / 375

            lblPlaceHolder.frame = CGRect(
                x: placeHolderXPosstion(true),
                y: frame.origin.y - (heightOfLable / 2),
                width: frame.size.width,
                height: heightOfLable
            )

            updateWidthOfPlaceholder(true)
        } else {
            updateWidthOfPlaceholder(false)
        }
    }

    func updatePlaceholderFrame(_ isMoveUp: Bool?) {
        // Hide Placeholder
        if tag == 1 || tag == 3 {
            lblPlaceHolder.isHidden = isMoveUp!
            return
        }

        // Animation will not perform for fixed placholder at top.
        if fixedAtTop {
            return
        }

        // Move Placeholder
        if isMoveUp! {
            UIView.animate(withDuration: AnimationDuration) {
                self.lblPlaceHolder.textColor = .lightGray
                self.lblPlaceHolder.attributedText = self.placeHolder.highlightedPlaceholder()

                let heightOfLable: CGFloat = CScreenWidth * 16 / 375
                self.lblPlaceHolder.frame = CGRect(
                    x: self.placeHolderXPosstion(true),
                    y: self.frame.origin.y - (heightOfLable / 2),
                    width: self.frame.size.width,
                    height: heightOfLable
                )

                self.lblPlaceHolder.font = UIFont(
                    name: (self.font?.fontName)!,
                    size: round(CScreenWidth * (self.placeholderFontSize - 2) / 375)
                )

                self.layoutIfNeeded()
                self.updateWidthOfPlaceholder(true)
            }
        } else {
            UIView.animate(withDuration: AnimationDuration) {
                self.lblPlaceHolder.textColor = .lightGray
                self.lblPlaceHolder.attributedText = self.placeHolder.highlightedPlaceholder()

                self.lblPlaceHolder.frame = CGRect(
                    x: self.placeHolderXPosstion(false),
                    y: self.frame.origin.y + 5,
                    width: self.frame.size.width,
                    height: self.frame.size.height - 10
                )

                self.lblPlaceHolder.font = UIFont(
                    name: (self.font?.fontName)!,
                    size: round(CScreenWidth * (self.placeholderFontSize) / 375)
                )

                self.layoutIfNeeded()
                self.updateWidthOfPlaceholder(false)
            }
        }
    }

    private func placeHolderXPosstion(_ isSmallHeight: Bool) -> CGFloat {
        var xPossition: CGFloat = 0.0

        if isSmallHeight {
            xPossition = frame.origin.x + placeHolderLeftPaddingAfterAnimation
        } else {
            xPossition = frame.origin.x + placeHolderLeftPadding
        }

        if showLeftView {
            xPossition = frame.height + 5 + frame.origin.x
        }

        return xPossition
    }

    private func updateWidthOfPlaceholder(_ isSmallHeight: Bool) {
        lblPlaceHolder.sizeToFit()
        lblPlaceHolder.frame.size.height = isSmallHeight ? CScreenWidth * 16 / 375 : frame.size.height - 10

        var maxWidth: CGFloat = frame.size.width

        if showLeftView {
            maxWidth = maxWidth - frame.size.height - 5
        } else {
            maxWidth = maxWidth - placeHolderLeftPaddingAfterAnimation
        }

        if showRightView {
            maxWidth = maxWidth - frame.size.height - 5
        } else {
            maxWidth = maxWidth - placeHolderLeftPaddingAfterAnimation
        }

        // If placeholder widht is out of bound.
        if lblPlaceHolder.frame.size.width > maxWidth {
            lblPlaceHolder.frame.size.width = maxWidth
        }
    }
}

// MARK: - -------- Bottom Line

extension FloatingTextField {
    private func bottomLineViewSetup() {
        viewBottomLine.frame = CGRect(x: 0.0, y: frame.size.height - 1, width: frame.size.width, height: 1.0)
        viewBottomLine.backgroundColor = bottomLineColor
        addSubview(viewBottomLine)
    }

    func updatedBottomLineColor(_ isNormalColor: Bool) {
        viewBottomLine.backgroundColor = isNormalColor ? bottomLineColor : bottomLineSelectedColor
    }
}

// MARK: - -------- Right view

extension FloatingTextField {
    func rightViewSetup(rightViewImage: UIImage) {
        btnRightView.frame = CGRect(
            x: 0.0,
            y: 0,
            width: frame.size.height,
            height: frame.size.height
        )

        btnRightView.setImage(rightViewImage, for: .normal)
        rightViewMode = .always
        rightView = btnRightView

        btnRightView.addTarget(
            self,
            action: #selector(rightViewButtonClick(_:)),
            for: .touchUpInside
        )
    }

    @objc func rightViewButtonClick(_: UIButton) {
        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldRightViewClick?(self)
    }
}

// MARK: - -------- Left view

extension FloatingTextField {
    private func leftViewSetup() {
        btnLeftView.frame = CGRect(
            x: 0.0,
            y: 0,
            width: frame.size.height,
            height: frame.size.height
        )

        btnLeftView.setImage(leftViewImage, for: .normal)

        leftViewMode = .always
        leftView = btnLeftView

        btnLeftView.addTarget(
            self,
            action: #selector(leftViewButtonClick(_:)),
            for: .touchUpInside
        )
    }

    @objc func leftViewButtonClick(_: UIButton) {
        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldLeftViewClick?(self)
    }
}

// MARK: - --------Textfiled Delegate methods

extension FloatingTextField {
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldDidChange?(textField)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) {
        // update placeholder frame
        updatePlaceholderFrame(true)

        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldShouldBeginEditing?(textField)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // update placeholder frame
        updatePlaceholderFrame(true)

        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldDidBeginEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if text?.count == 0 {
            // update placeholder frame
            updatePlaceholderFrame(false)
        }

        guard let delegate = txtDelegate else {
            return
        }

        _ = delegate.floatingTextFieldDidEndEditing?(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let delegate = txtDelegate else {
            return true
        }

        return delegate.floatingTextField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
