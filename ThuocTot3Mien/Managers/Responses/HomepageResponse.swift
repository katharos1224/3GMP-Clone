//
//  HomepageResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 06/12/2023.
//

import Foundation

struct HomepageResponse: Codable {
    let code: Int
    let message: [String]
    let response: HomepageResponseData?
}

struct HomepageResponseData: Codable {
    let banners: [Banner]
    let events: [String?]
    let products: [Product]
    let totalCart: Int
    let totalNotifications: Int
    let memberName: String
    let memberStatus: Int
    let iconRank: String

    init(banners: [Banner], events: [String?], products: [Product], totalCart: Int, totalNotifications: Int, memberName: String, memberStatus: Int, iconRank: String) {
        self.banners = banners
        self.events = events
        self.products = products
        self.totalCart = totalCart
        self.totalNotifications = totalNotifications
        self.memberName = memberName
        self.memberStatus = memberStatus
        self.iconRank = iconRank
    }

    private enum CodingKeys: String, CodingKey {
        case banners
        case events
        case products
        case totalCart = "total_cart"
        case totalNotifications = "total_notifications"
        case memberName = "member_name"
        case memberStatus = "member_status"
        case iconRank = "thu_hang_icon"
    }
}

struct Banner: Codable {
    let key: String?
    let value: String
}

// struct Event: Codable {
//    let even: [String]
// }

struct Product: Codable {
    let key: String
    let value: String
    let name: String
    var data: [ProductData]
}

struct ProductData: Codable {
    let id: Int
    let khuyenMai: Double?
    let tenSanPham: String
    let quyCachDongGoi: String?
    var soLuong: Int
    let donGia: Int
    let bonusCoins: Int?
    let soLuongToiThieu: Int?
    let soLuongToiDa: Int?
    let imgUrl: String?
    var discountPrice: Double
    let detailUrl: String
    let tags: [Tag]

    private enum CodingKeys: String, CodingKey {
        case id
        case khuyenMai = "khuyen_mai"
        case tenSanPham = "ten_san_pham"
        case quyCachDongGoi = "quy_cach_dong_goi"
        case soLuong = "so_luong"
        case donGia = "don_gia"
        case bonusCoins = "bonus_coins"
        case soLuongToiThieu = "so_luong_toi_thieu"
        case soLuongToiDa = "so_luong_toi_da"
        case imgUrl = "img_url"
        case discountPrice = "discount_price"
        case detailUrl = "detail_url"
        case tags
    }
}

struct Tag: Codable {
    let key: String
    let value: Int
    let name: String
}
