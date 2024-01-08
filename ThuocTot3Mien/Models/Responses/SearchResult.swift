//
//  SearchResult.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 28/12/2023.
//

import Foundation

// MARK: - SearchResult

struct SearchResult: Codable {
    let code: Int
    let message: [String]
    let response: [SearchData]?
}

// MARK: - Response

struct SearchData: Codable {
    let id: Int
    let tenSanPham: String
    let banChay: Int
    let khuyenMai: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case tenSanPham = "ten_san_pham"
        case banChay = "ban_chay"
        case khuyenMai = "khuyen_mai"
    }
}
