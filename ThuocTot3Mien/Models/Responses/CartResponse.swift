//
//  CartResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 11/12/2023.
//

import Foundation

// MARK: - Added Products

struct AddedProductsResponse: Codable {
    let code: Int
    let message: [String]
    let response: AddedProductsData?
}

struct AddedProductsData: Codable {
    let products: AddedProductList
    let totalNumber: Int
    let totalPrice: Int
    let tiLeGiam: String

    enum CodingKeys: String, CodingKey {
        case products
        case totalNumber = "total_number"
        case totalPrice = "total_price"
        case tiLeGiam = "ti_le_giam"
    }
}

struct AddedProductList: Codable {
    let currentPage: Int
    let data: [AddedProduct]
    let firstPageUrl: String
    let from: Int
    let lastPage: Int
    let lastPageUrl: String
    let nextPageUrl: String?
    let path: String
    let perPage: Int
    let prevPageUrl: String?
    let to: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageUrl = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageUrl = "last_page_url"
        case nextPageUrl = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageUrl = "prev_page_url"
        case to
        case total
    }
}

struct AddedProduct: Codable {
    let gioHangId: Int
    let idMember: Int
    let id: Int
    let soLuong: Int
    let tenSanPham: String
    let quyCachDongGoi: String?
    let khuyenMai: Int?
    let donGia: Int
    let giaUuDai: String?
    let idSpKm: Int?
    let soLuongKm: Int?
    let soLuongToiThieu: Int?
    let soLuongToiDa: Int?
    let ngayHetHan: String?
    let imgUrl: String?
    let imgSpKm: String?
    let discountPrice: Double
    let detailUrl: String?

    enum CodingKeys: String, CodingKey {
        case gioHangId = "gio_hang_id"
        case idMember = "id_member"
        case id
        case soLuong = "so_luong"
        case tenSanPham = "ten_san_pham"
        case quyCachDongGoi = "quy_cach_dong_goi"
        case khuyenMai = "khuyen_mai"
        case donGia = "don_gia"
        case giaUuDai = "gia_uu_dai"
        case idSpKm = "id_sp_km"
        case soLuongKm = "so_luong_km"
        case soLuongToiThieu = "so_luong_toi_thieu"
        case soLuongToiDa = "so_luong_toi_da"
        case ngayHetHan = "ngay_het_han"
        case imgUrl = "img_url"
        case imgSpKm = "img_sp_km"
        case discountPrice = "discount_price"
        case detailUrl = "detail_url"
    }
}

// MARK: - Cart

struct CartResponse: Codable {
    let code: Int
    let message: [String]
    let response: CartResponseData?
}

struct CartResponseData: Codable {
    let products: CartList
    let totalNumber: Int
    let totalPrice: Int
    let tiLeGiam: String

    enum CodingKeys: String, CodingKey {
        case products
        case totalNumber = "total_number"
        case totalPrice = "total_price"
        case tiLeGiam = "ti_le_giam"
    }
}

struct CartList: Codable {
    let currentPage: Int
    let data: [CartProduct]
    let firstPageUrl: String
    let from: Int?
    let lastPage: Int?
    let lastPageUrl: String?
    let nextPageUrl: String?
    let path: String?
    let perPage: Int?
    let prevPageUrl: String?
    let to: Int?
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageUrl = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageUrl = "last_page_url"
        case nextPageUrl = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageUrl = "prev_page_url"
        case to
        case total
    }
}

struct CartProduct: Codable {
    let gioHangId: Int
    let idMember: Int
    let id: Int
    var soLuong: Int
    let tenSanPham: String
    let quyCachDongGoi: String?
    let khuyenMai: Double?
    let donGia: Int
    let giaUuDai: String?
    let idSpKm: Int?
    let soLuongKm: Int?
    let soLuongToiThieu: Int?
    let soLuongToiDa: Int?
    let ngayHetHan: String?
    let bonusCoins: Int
    let imgUrl: String?
    let imgSpKm: String?
    let discountPrice: Double
    let detailUrl: String?
    let tags: [Tag]?

    enum CodingKeys: String, CodingKey {
        case gioHangId = "gio_hang_id"
        case idMember = "id_member"
        case id
        case soLuong = "so_luong"
        case tenSanPham = "ten_san_pham"
        case quyCachDongGoi = "quy_cach_dong_goi"
        case khuyenMai = "khuyen_mai"
        case donGia = "don_gia"
        case giaUuDai = "gia_uu_dai"
        case idSpKm = "id_sp_km"
        case soLuongKm = "so_luong_km"
        case soLuongToiThieu = "so_luong_toi_thieu"
        case soLuongToiDa = "so_luong_toi_da"
        case ngayHetHan = "ngay_het_han"
        case bonusCoins = "bonus_coins"
        case imgUrl = "img_url"
        case imgSpKm = "img_sp_km"
        case discountPrice = "discount_price"
        case detailUrl = "detail_url"
        case tags
    }
}
