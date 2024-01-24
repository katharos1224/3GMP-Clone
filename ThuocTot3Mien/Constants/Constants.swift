//
//  Constants.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 17/01/2024.
//

import Foundation
import UIKit

enum Constants {
    static let WIDTH_SCREEN = UIScreen.main.bounds.width
    static let HEIGHT_SCREEN = UIScreen.main.bounds.height
    static let PADDING = 16.0
    static let PADDING_ZERO = 0.0
    static let SPACING = 16.0
    static let SPACING_ZERO = 16.0
}

enum EndPointURL {
    static let BASE_API_URL: String = Config.shared.BASE_API_URL + Config.shared.API_VERSION
    static let PROVINCES: String = "system/provinces"
    static let AGENCY: String = "system/provinces/agency_list"
    static let LOGIN: String = "member/login"
    static let REGISTER: String = "member/register"
    static let CUSTOMER_LOGIN: String = "customer/login"
    static let CUSTOMER_REGISTER: String = "customer/register"
    static let HOMEPAGE: String = "system/homepage"
    static let CART_UPDATE: String = "cart/update"
    static let CART: String = "cart/index"
    static let VOUCHER: String = "cart/list_voucher"
    static let DISCOUNT: String = "cart/discount"
    static let PAYMENT: String = "cart/payment"
    static let CATEGORY: String = "system/category"
    static let CATEGORY_TYPE: String = "system/category_type"
    static let PRODUCT: String = "product/index"
    static let SEARCH: String = "search"
    static let HISTORY: String = "history/payment"
    static let HISTORY_DETAIL: String = "history/payment_details"
    static let CONTACT: String = "system/contact"
    static let NEWS: String = "system/list_news"
    static let PROFILE: String = "member/profile"
    static let LOGOUT: String = "member/logout"
    static let GENERAL_INFO: String = "http://18.138.176.213/system/general_information/"
    static let AGENCY_CATEGORY: String = "agency/category"
    static let AGENCY_PRODUCTS: String = "agency/products"
    static let SHOW_PRODUCT: String = "agency/product/change_of_status"
    static let PIN_BEST_SELLER: String = "agency/product/bestseller"
    static let DELETE_PRODUCT: String = "agency/product/delete"
    static let AGENCY_CATEGORY_TYPE: String = "agency/category_type"
    static let AGENCY_CATEGORY_TYPE_CREATE: String = "agency/category_type/create"
    static let AGENCY_CATEGORY_TYPE_EDIT: String = "agency/category_type/edit"
    static let AGENCY_CATEGORY_TYPE_DELETE: String = "agency/category_type/delete"
}

enum TabItemTitles: String {
    case home = "Trang chủ"
    case category = "Danh mục"
    case history = "Lịch sử"
    case management = "Quản lý"

    var localized: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}

enum TabItemIcons: String {
    case home = "house.fill"
    case category = "cart.fill"
    case history = "clock.arrow.circlepath"
    case management = "info.circle.fill"
}

enum Colors {
    static let COLOR_BAR_BACKGROUND = UIColor(red: 251 / 255, green: 251 / 255, blue: 204 / 255, alpha: 1.0)
    static let COLOR_BAR_TINT = UIColor(red: 251 / 255, green: 251 / 255, blue: 204 / 255, alpha: 1.0)
    static let COLOR_TINT = UIColor(red: 79 / 255, green: 183 / 255, blue: 94 / 255, alpha: 1.0)
    static let COLOR_BACKGROUND = UIColor(red: 70 / 255, green: 183 / 255, blue: 85 / 255, alpha: 1.0)
}
