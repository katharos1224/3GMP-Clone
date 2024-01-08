//
//  HistoryVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import UIKit
import LZViewPager

final class HistoryVC: BaseViewController {
    
    @IBOutlet weak var viewPager: LZViewPager!
    
    var subControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewPagerProperties()
    }

    override func viewWillAppear(_: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func viewPagerProperties() {
        viewPager.delegate = self
        viewPager.dataSource = self
        viewPager.hostController = self
        
        let vc1 = PaymentHistoryVC()
        let vc2 = ViewController2()
        subControllers = [vc1, vc2]
        viewPager.backgroundColor = .white
        viewPager.reload()
    }
}

extension HistoryVC: LZViewPagerDelegate, LZViewPagerDataSource {
    func numberOfItems() -> Int {
        return subControllers.count
    }
    
    func controller(at index: Int) -> UIViewController {
        return subControllers[index]
    }
    
    func button(at index: Int) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGray4
        button.setTitle(index == 0 ? "Lịch sử mua" : "Lịch sử bán", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }
    
    func colorForIndicator(at index: Int) -> UIColor {
        return .systemGreen
    }
    
    func buttonsAligment() -> ButtonsAlignment {
        return .center
    }
    
    func heightForHeader() -> CGFloat {
        return 1/13 * UIScreen.main.bounds.height
    }
    
    func heightForIndicator() -> CGFloat {
        return 8
    }
}