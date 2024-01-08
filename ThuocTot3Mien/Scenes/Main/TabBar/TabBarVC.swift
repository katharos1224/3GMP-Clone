//
//  TabBarVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import UIKit
import Combine

final class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 204/255, alpha: 1.0)

        let homeVC = HomeVC()
        let productVC = CategoryVC()
        let historyVC = HistoryVC()
        let infoVC = InfoVC()

        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: productVC)
        let nav3 = UINavigationController(rootViewController: historyVC)
        let nav4 = UINavigationController(rootViewController: infoVC)

        nav1.tabBarItem = UITabBarItem(title: "Trang chủ", image: UIImage(systemName: "house.fill"), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Danh mục", image: UIImage(systemName: "cart.fill"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Lịch sử", image: UIImage(systemName: "clock.arrow.circlepath"), tag: 2)
        nav4.tabBarItem = UITabBarItem(title: "Thông tin", image: UIImage(systemName: "info.circle.fill"), tag: 3)

        setViewControllers([nav1, nav2, nav3, nav4], animated: true)

        customizeTabBarAppearance()
    }

    private func customizeTabBarAppearance() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor(red: 251/255, green: 251/255, blue: 204/255, alpha: 1.0)
        tabBar.tintColor = UIColor(red: 79/255, green: 183/255, blue: 94/255, alpha: 1.0)
        tabBar.unselectedItemTintColor = .black
        tabBar.selectedItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGreen], for: .selected)
    }
}
