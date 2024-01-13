//
//  NewsResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Foundation

struct NewsResponse: Codable {
    let code: Int
    let message: [String]
    let response: NewsData?
}

struct NewsData: Codable {
    let currentPage: Int
    let data: [NewsItem]
    let firstPageURL: String
    let from: Int
    let lastPage: Int
    let lastPageURL: String
    let nextPageURL: String?
    let path: String
    let perPage: Int
    let prevPageURL: String?
    let to: Int
    let total: Int

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

struct NewsItem: Codable {
    let id: Int
    let title: String
    let description: String
    let imageURL: String
    let publishDate: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case title = "tieu_de"
        case description = "mo_ta"
        case imageURL = "img"
        case publishDate = "ngay_cong_khai"
        case url
    }
}
