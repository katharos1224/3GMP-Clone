//
//  ProductsResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 27/12/2023.
//

import Foundation

// MARK: - CategoryProducts

struct CategoryProducts: Codable {
    let code: Int
    let message: [String]
    let response: CategoryProductsResponse?
}

struct AgencyProducts: Codable {
    let code: Int
    let message: [String]
    let response: AgencyProductsResponse?
}

// MARK: - CategoryProductsResponse

struct CategoryProductsResponse: Codable {
    let currentPage: Int
    let data: [CategoryProduct]
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

struct AgencyProductsResponse: Codable {
    let currentPage: Int
    let data: [AgencyProduct]
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

// MARK: - CategoryProduct

struct CategoryProduct: Codable {
    let id: Int
    let khuyenMai: Double?
    let tenSanPham: String
    let quyCachDongGoi: String?
    let soLuong, donGia: Int
    let giaUuDai: String?
    let soLuongToiThieu, soLuongToiDa: Int?
    let imgURL: String
    let discountPrice: Double
    let detailURL: String
    let tags: [Tag]
    let imgSanPhams, productTags: [ImgSanPhams]
    let hoatChatSanPhams: [HoatChatSanPham]

    enum CodingKeys: String, CodingKey {
        case id
        case khuyenMai = "khuyen_mai"
        case tenSanPham = "ten_san_pham"
        case quyCachDongGoi = "quy_cach_dong_goi"
        case soLuong = "so_luong"
        case donGia = "don_gia"
        case giaUuDai = "gia_uu_dai"
        case soLuongToiThieu = "so_luong_toi_thieu"
        case soLuongToiDa = "so_luong_toi_da"
        case imgURL = "img_url"
        case discountPrice = "discount_price"
        case detailURL = "detail_url"
        case tags
        case imgSanPhams = "img_san_phams"
        case productTags = "product_tags"
        case hoatChatSanPhams = "hoatchat_san_phams"
    }
}

struct AgencyProduct: Codable {
    let id: Int
    let khuyenMai: Double?
    let tenSanPham: String
    let quyCachDongGoi: String?
    let soLuong, donGia, banChay, trangThai: Int
    let giaUuDai: String?
    let soLuongToiThieu, soLuongToiDa: Int?
    let imgURL: String
    let discountPrice: Double
    let detailURL: String
    let imgSanPhams, productTags: [ImgSanPhams]
    let hoatChatSanPhams: [HoatChatSanPham]

    enum CodingKeys: String, CodingKey {
        case id
        case khuyenMai = "khuyen_mai"
        case tenSanPham = "ten_san_pham"
        case quyCachDongGoi = "quy_cach_dong_goi"
        case soLuong = "so_luong"
        case donGia = "don_gia"
        case giaUuDai = "gia_uu_dai"
        case soLuongToiThieu = "so_luong_toi_thieu"
        case soLuongToiDa = "so_luong_toi_da"
        case banChay = "ban_chay"
        case trangThai = "trang_thai"
        case imgURL = "img_url"
        case discountPrice = "discount_price"
        case detailURL = "detail_url"
        case imgSanPhams = "img_san_phams"
        case productTags = "product_tags"
        case hoatChatSanPhams = "hoatchat_san_phams"
    }
}

// MARK: - HoatchatSanPham

struct HoatChatSanPham: Codable {
    let id, idSanPham, idHoatChat: Int
    let hamLuong, createdAt: String
    let updatedAt, deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idSanPham = "id_san_pham"
        case idHoatChat = "id_hoat_chat"
        case hamLuong = "ham_luong"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - ImgSanPham

struct ImgSanPhams: Codable {
    let id, idSanPham: Int
    let img: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idSanPham = "id_san_pham"
        case img
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
