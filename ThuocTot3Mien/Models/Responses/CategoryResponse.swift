//
//  CategoryResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 26/12/2023.
//

import Foundation

// MARK: - CategoryResponse

struct CategoryResponse: Codable {
    let code: Int
    let message: [String]
    let response: [CategoryResponseData]?
}

// MARK: - Response

struct CategoryResponseData: Codable {
    let name, key: String
    let icon: String
    let category: [Category]
}

// MARK: - Category

struct Category: Codable {
    let value: Int
    let name: String
}

// Categories Data

// MARK: - CategoryDetailResponse

struct CategoryDetailResponse: Codable {
    let code: Int
    let message: [String]
    let response: CategoryDetailResponseData?
}

// MARK: - Response

struct CategoryDetailResponseData: Codable {
    let currentPage: Int
    let data: [Category]
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
        case to
        case total
    }
}
