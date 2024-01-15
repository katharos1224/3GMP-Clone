//
//  OrderDetailResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 03/01/2024.
//

import Foundation

struct OrderDetailResponse: Codable {
    let code: Int
    let message: [String]
    let response: OrderDetailResponseData?
}

struct OrderDetailResponseData: Codable {
    let products: OrderedProducts
    let totalProducts: Int
    let dateTime: String
    let totalPrice: Int
    let price: Int
    let coin: Int?
    let coinValue: Int?
    let coinBonus: Int?
    let voucher: String?
    let voucherValue: Int?
    let transferred: Int?
    let transferredValue: Int?
    let ghiChu: String?

    enum CodingKeys: String, CodingKey {
        case products
        case totalProducts = "total_products"
        case dateTime = "date_time"
        case totalPrice = "total_price"
        case price
        case coin
        case coinValue = "coin_value"
        case coinBonus = "coin_bonus"
        case voucher
        case voucherValue = "voucher_value"
        case transferred
        case transferredValue = "transferred_value"
        case ghiChu = "ghi_chu"
    }
}

struct OrderedProducts: Codable {
    let currentPage: Int
    let data: [OrderedProductItem]
    let firstPageURL: String
    let from, lastPage: Int?
    let lastPageURL, nextPageURL, path: String?
    let perPage: Int
    let prevPageURL: String?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to, total
    }
}

struct OrderedProductItem: Codable {
    let soLuong: Int
    let donGia: Int
    let discountPrice: Double
    let bonusCoins: Int?
    let id: Int
    let tenSanPham: String
    let imgUrl: String?
    let khuyenMai: Int?
    let detailUrl: String
    let tags: [Tag]?

    enum CodingKeys: String, CodingKey {
        case soLuong = "so_luong"
        case donGia = "don_gia"
        case discountPrice = "discount_price"
        case bonusCoins = "bonus_coins"
        case id
        case tenSanPham = "ten_san_pham"
        case imgUrl = "img_url"
        case khuyenMai = "khuyen_mai"
        case detailUrl = "detail_url"
        case tags
    }
}
