//
//  AgencyCategoryResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 22/01/2024.
//

import Foundation

struct AgencyCategoryResponse: Codable {
    let code: Int
    let message: [String]
    let response: [AgencyCategory]?
}

struct AgencyCategory: Codable {
    let name: String
    let key: String
    let icon: String
    let category: [AgencyCategoryData]
}

struct AgencyCategoryData: Codable {
    let value: Int
    let name: String
}
