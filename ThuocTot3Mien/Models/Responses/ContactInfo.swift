//
//  ContactInfo.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/01/2024.
//

import Foundation

struct ContactInfo: Codable {
    let code: Int
    let message: [String]
    let response: [ContactMethod]
}

struct ContactMethod: Codable {
    let icon: String
    let name: String
    let value: String
    let type: Int

    enum CodingKeys: String, CodingKey {
        case icon
        case name
        case value
        case type
    }
}
