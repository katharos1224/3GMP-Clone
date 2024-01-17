//
//  TabBarVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 05/12/2023.
//

import Combine
import UIKit

final class TabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = HomeVC()
        let productVC = CategoryVC()
        let historyVC = HistoryVC()
        let infoVC = ManagementVC()

        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: productVC)
        let nav3 = UINavigationController(rootViewController: historyVC)
        let nav4 = UINavigationController(rootViewController: infoVC)

        nav1.tabBarItem = UITabBarItem(title: TabItemTitles.home.rawValue, image: UIImage(systemName: TabItemIcons.home.rawValue), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: TabItemTitles.category.rawValue, image: UIImage(systemName: TabItemIcons.category.rawValue), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: TabItemTitles.history.rawValue, image: UIImage(systemName: TabItemIcons.history.rawValue), tag: 2)
        nav4.tabBarItem = UITabBarItem(title: TabItemTitles.management.rawValue, image: UIImage(systemName: TabItemIcons.management.rawValue), tag: 3)

        setViewControllers([nav1, nav2, nav3, nav4], animated: false)

        customizeTabBarAppearance()
    }

    private func customizeTabBarAppearance() {
        view.backgroundColor = Colors.COLOR_BACKGROUND
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.isTranslucent = false
        tabBar.barTintColor = Colors.COLOR_BAR_TINT
        tabBar.tintColor = Colors.COLOR_TINT
        tabBar.unselectedItemTintColor = .black
        tabBar.selectedItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGreen], for: .selected)
    }
}
