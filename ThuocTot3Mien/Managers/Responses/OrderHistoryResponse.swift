//
//  OrderHistoryResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 03/01/2024.
//

import Foundation

struct OrderHistoryResponse: Codable {
    let code: Int
    let message: [String]?
    let response: OrderHistoryData?
}

struct OrderHistoryData: Codable {
    let currentPage: Int?
    let data: [OrderHistoryItem]?
    let firstPageURL: URL?
    let from: Int?
    let lastPage: Int?
    let lastPageURL: URL?
    let nextPageURL: URL?
    let path: URL?
    let perPage: Int?
    let prevPageURL: URL?
    let to: Int?
    let total: Int?

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
        case to
        case total
    }
}

struct OrderHistoryItem: Codable {
    let id: Int?
    let maDonHang: String?
    let diaChi: String?
    let createdAt: String?
    let ckTruoc: Int?
    let tiLeGiam: Double?
    let trangThai: Int?
    let voucher: String?
    let voucherValue: Double?
    let coins: Int?
    let coinValue: Int?
    let ghiChu: String?
    let tongTien: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case maDonHang = "ma_don_hang"
        case diaChi = "dia_chi"
        case createdAt = "created_at"
        case ckTruoc = "ck_truoc"
        case tiLeGiam = "ti_le_giam"
        case trangThai = "trang_thai"
        case voucher
        case voucherValue = "voucher_value"
        case coins
        case coinValue = "coin_value"
        case ghiChu = "ghi_chu"
        case tongTien = "tong_tien"
    }
}
