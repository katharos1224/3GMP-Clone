//
//  LZViewPagerContent.swift
//
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import SnapKit
import UIKit

extension UIViewController {
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

extension UIPageViewController {
    var isScrollEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}

class LZViewPagerContent: UIView, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    weak var delegate: LZViewPagerDelegate?
    weak var dataSource: LZViewPagerDataSource?
    weak var hostController: UIViewController?
    var currentIndex: Int?
    var onSelectionChanged: ((_ newIndex: Int) -> Void)?

    var shouldEnableSwipeable: Bool {
        if let e = dataSource?.shouldEnableSwipeable?() {
            return e
        } else {
            return true
        }
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controllerCounts = dataSource?.numberOfItems() ?? 0
        let currentIndex = viewController.index
        if currentIndex == controllerCounts - 1 {
            return nil
        }
        let controller = dataSource?.controller(at: currentIndex + 1)
        controller?.index = currentIndex + 1
        return controller
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.index
        if currentIndex == 0 {
            return nil
        }
        let controller = dataSource?.controller(at: currentIndex - 1)
        controller?.index = currentIndex - 1
        return controller
    }

    func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        delegate?.willTransition?(to: pendingViewControllers[0].index)
    }

    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = (pageViewController!.viewControllers![0]).index
            onSelectionChanged?(currentIndex!)
            delegate?.didTransition?(to: currentIndex!)
        }
    }

    private lazy var pageViewController: UIPageViewController? = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.delegate = self
        pvc.dataSource = self
        return pvc
    }()

    func scroll(to index: Int, animated: Bool = true) {
        if let controller = dataSource?.controller(at: index) {
            controller.index = index
            if let currentIndex = (pageViewController?.viewControllers?[0])?.index {
                if index == currentIndex {
                    return
                } else if index > currentIndex {
                    pageViewController?.setViewControllers([controller], direction: .forward, animated: animated, completion: nil)
                } else {
                    pageViewController?.setViewControllers([controller], direction: .reverse, animated: animated, completion: nil)
                }
            } else {
                pageViewController?.setViewControllers([controller], direction: .forward, animated: animated, completion: nil)
            }
            currentIndex = index
        }
    }

    public func reload() {
        guard var index = currentIndex, let itemsCount = dataSource?.numberOfItems() else {
            return
        }
        if index >= itemsCount {
            index = 0
            currentIndex = 0
        }
        guard let _ = hostController else {
            assertionFailure("You must specify a host controller")
            return
        }
        if let pvc = pageViewController {
            if let _ = pvc.view.superview {
                pvc.willMove(toParent: nil)
                pvc.view.removeFromSuperview()
                pvc.didMove(toParent: nil)
                pvc.removeFromParent()
            }
            hostController?.addChild(pvc)
            pvc.willMove(toParent: hostController)
            addSubview(pvc.view)
            pvc.didMove(toParent: hostController)
            pvc.isScrollEnabled = shouldEnableSwipeable
        }
        guard let count = dataSource?.numberOfItems(), count > 0 else { return }
        if let first = dataSource?.controller(at: index) {
            pageViewController?.setViewControllers([first], direction: .forward, animated: false, completion: nil)
            first.index = index
        }
        for view in pageViewController?.view.subviews ?? [] {
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).delaysContentTouches = false
                (view as! UIScrollView).canCancelContentTouches = true
            }
        }
        pageViewController?.view.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
