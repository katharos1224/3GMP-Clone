//
//  Province.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 01/12/2023.
//

import Foundation

// MARK: - Province Data

struct ProvincesData: Codable {
    let code: Int
    let message: [String?]
    let response: [Province]
}

struct Province: Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "ten"
    }
}
