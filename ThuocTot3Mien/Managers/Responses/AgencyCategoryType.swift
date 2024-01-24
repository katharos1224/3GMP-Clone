//
//  AgencyCategoryTypeResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import Foundation

struct AgencyCategoryTypeResponse: Codable {
    let code: Int
    let message: [String]
    let response: AgencyCategoryTypeResponseData?
}

struct AgencyCategoryTypeResponseData: Codable {
    let currentPage: Int
    let data: [AgencyCategoryType]
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

    private enum CodingKeys: String, CodingKey {
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

struct AgencyCategoryType: Codable {
    let value: Int
    let name: String
    let size: Int
}
