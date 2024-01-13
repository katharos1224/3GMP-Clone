//
//  LZViewPagerHeader.swift
//
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import UIKit

extension UIButton {
    private enum LZRuntimeKey {
        static let indexKey = UnsafeRawPointer(bitPattern: "indexKey".hashValue)
    }

    public var index: Int {
        set {
            objc_setAssociatedObject(self, LZRuntimeKey.indexKey!, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return (objc_getAssociatedObject(self, LZRuntimeKey.indexKey!) as! NSNumber).intValue
        }
    }
}

class LZViewPagerHeader: UIScrollView {
    weak var pagerDelegate: LZViewPagerDelegate?
    weak var dataSource: LZViewPagerDataSource?
    var onSelectionChanged: ((_ newIndex: Int, _ animated: Bool) -> Void)?
    var currentIndex: Int?

    private lazy var containerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.clear
        return v
    }()

    private lazy var contentView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.clear
        return v
    }()

    private lazy var indicatorView: UIView = .init(frame: CGRect.zero)

    private var buttonsWidth: CGFloat {
        guard let buttonsCount = dataSource?.numberOfItems(), buttonsCount > 0 else {
            return 0
        }
        if let _ = dataSource?.widthForButton?(at: 0) {
            var totalWidth: CGFloat = 0
            for i in 0 ..< buttonsCount {
                totalWidth += dataSource!.widthForButton!(at: i)
            }
            return totalWidth
        } else {
            return bounds.width
        }
    }

    private var indicatorHeight: CGFloat {
        if let shouldShowIndicator = dataSource?.shouldShowIndicator?() {
            if !shouldShowIndicator {
                return 0
            }
            return dataSource?.heightForIndicator?() ?? LZConstants.defaultIndicatorHight
        } else {
            return dataSource?.heightForIndicator?() ?? LZConstants.defaultIndicatorHight
        }
    }

    private func buttonWidth(at index: Int) -> CGFloat {
        guard let buttonsCount = dataSource?.numberOfItems(), buttonsCount > 0 else {
            return 0
        }
        if let _ = dataSource?.widthForButton?(at: 0) {
            return dataSource!.widthForButton!(at: index)
        } else {
            return bounds.width / CGFloat(buttonsCount)
        }
    }

    private func buttonXLeading(for index: Int) -> CGFloat {
        if index < 0 {
            return 0
        }
        var offest: CGFloat = 0
        for i in 0 ..< index {
            offest += buttonWidth(at: i)
        }
        return offest
    }

    private var buttonsAlignment: ButtonsAlignment {
        if let aligment = dataSource?.buttonsAligment?() {
            return aligment
        } else {
            return .left
        }
    }

    private func indicatorWidth(at index: Int) -> CGFloat {
        guard let buttonsCount = dataSource?.numberOfItems(), buttonsCount > 0 else {
            return 0
        }
        if let _ = dataSource?.widthForIndicator?(at: 0) {
            return dataSource!.widthForIndicator!(at: index)
        } else {
            return buttonWidth(at: index)
        }
    }

    private func indicatorXLeading(for index: Int) -> CGFloat {
        if index < 0 {
            return 0
        }
        if let _ = dataSource?.widthForIndicator?(at: 0) {
            let leading = buttonXLeading(for: index)
            let buttonWidth = self.buttonWidth(at: index)
            let indicatorWidth = dataSource!.widthForIndicator!(at: index)
            if buttonWidth > indicatorWidth {
                return leading + (buttonWidth - indicatorWidth) * 0.5
            } else {
                return leading
            }
        } else {
            return buttonXLeading(for: index)
        }
    }

    @objc func buttonAction(sender: UIButton) {
        selectPage(at: sender.index)
    }

    func selectPage(at index: Int, animated: Bool = true) {
        move(to: index, animated: animated)
        pagerDelegate?.didSelectButton?(at: index)
        onSelectionChanged?(index, animated)
    }

    func move(to index: Int, animated: Bool = true) {
        for view in contentView.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                if button.index == index {
                    button.isSelected = true
                } else {
                    (view as! UIButton).isSelected = false
                }
            }
        }
        if indicatorHeight > 0 {
            moveIndicator(to: index, animated: animated)
        }
        currentIndex = index
        makeButtonCenteredIfNeeded(at: index, animated: animated)
    }

    private func makeButtonCenteredIfNeeded(at index: Int, animated: Bool = true) {
        var targetButton: UIButton? = nil
        for view in contentView.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                if button.index == index {
                    targetButton = button
                }
            }
        }
        guard let button = targetButton else { return }
        guard let _ = button.superview else { return }
        let rect = contentView.convert(button.frame, to: self)
        scrollRectToVisibleCentered(rect, animated: animated)
    }

    public func reload() {
        if let idx = currentIndex, let buttonCount = dataSource?.numberOfItems() {
            if idx >= buttonCount {
                currentIndex = 0
            }
        }
        if bounds.size.width == 0 {
            return
        }

        for view in subviews {
            view.removeFromSuperview()
        }

        for view in containerView.subviews {
            view.removeFromSuperview()
        }

        for view in contentView.subviews {
            view.removeFromSuperview()
        }

        guard let buttonsCount = dataSource?.numberOfItems(), buttonsCount > 0 else {
            return
        }

        addSubview(containerView)
        containerView.snp.remakeConstraints { [weak self] make in
            guard let s = self else { return }
            make.width.equalTo(max(s.buttonsWidth, s.bounds.size.width))
            make.height.equalTo(s.bounds.size.height)
            if s.buttonsWidth > s.bounds.size.width {
                make.edges.equalToSuperview()
            } else {
                make.centerY.equalToSuperview()
                if s.buttonsAlignment == .left {
                    make.leading.equalTo(s.superview!.snp.leading)
                } else if s.buttonsAlignment == .center {
                    make.center.equalToSuperview()
                } else if s.buttonsAlignment == .right {
                    make.trailing.equalTo(s.superview!.snp.trailing)
                }
            }
        }
        containerView.addSubview(contentView)
        contentView.snp.remakeConstraints { [weak self] make in
            guard let s = self else { return }
            if s.buttonsAlignment == .left {
                make.leading.equalToSuperview()
            } else if s.buttonsAlignment == .center {
                make.center.equalToSuperview()
            } else if s.buttonsAlignment == .right {
                make.trailing.equalToSuperview()
            }
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(s.buttonsWidth)
        }
        for i in 0 ..< buttonsCount {
            if let button = dataSource?.button(at: i) {
                button.index = i
                contentView.addSubview(button)
                button.snp.remakeConstraints { [weak self] make in
                    guard let s = self else { return }
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview().offset(s.buttonXLeading(for: i))
                    make.width.equalTo(s.buttonWidth(at: i))
                    make.bottom.equalToSuperview().offset(-s.indicatorHeight)
                }
                if let _ = button.titleLabel?.text {
                } else {
                    let controller = dataSource?.controller(at: i)
                    button.setTitle(controller?.title, for: .normal)
                }
                button.addTarget(self, action: #selector(LZViewPagerHeader.buttonAction(sender:)), for: .touchUpInside)
                button.sizeToFit()
                if button.index == currentIndex {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
        }
        if indicatorHeight > 0 {
            setUpIndicator()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.makeButtonCenteredIfNeeded(at: self.currentIndex ?? 0, animated: false)
        }
    }

    private func setUpIndicator() {
        guard let index = currentIndex else { return }
        indicatorView.backgroundColor = dataSource?.colorForIndicator?(at: index) ?? LZConstants.defaultIndicatorColor
        contentView.addSubview(indicatorView)
        indicatorView.snp.remakeConstraints { [weak self] make in
            guard let s = self else { return }
            make.leading.equalToSuperview().offset(s.indicatorXLeading(for: index))
            make.width.equalTo(s.indicatorWidth(at: index))
            make.bottom.equalToSuperview()
            make.height.equalTo(s.indicatorHeight)
        }
    }

    private func moveIndicator(to index: Int, animated: Bool = true) {
        indicatorView.snp.remakeConstraints { [weak self] make in
            guard let s = self else { return }
            make.leading.equalToSuperview().offset(s.indicatorXLeading(for: index))
            make.width.equalTo(s.indicatorWidth(at: index))
            make.bottom.equalToSuperview()
            make.height.equalTo(s.indicatorHeight)
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorView.backgroundColor = self.dataSource?.colorForIndicator?(at: index) ?? LZConstants.defaultIndicatorColor
                self.contentView.layoutIfNeeded()
            }, completion: nil)
        } else {
            indicatorView.backgroundColor = dataSource?.colorForIndicator?(at: index) ?? LZConstants.defaultIndicatorColor
            contentView.layoutIfNeeded()
        }
    }

    private func scrollRectToVisibleCentered(_ rect: CGRect, animated: Bool) {
        let centedRect = CGRect(x: rect.origin.x + rect.size.width / 2.0 - frame.size.width / 2.0,
                                y: rect.origin.y + rect.size.height / 2.0 - frame.size.height / 2.0,
                                width: frame.size.width,
                                height: frame.size.height)
        scrollRectToVisible(centedRect, animated: animated)
    }
}
