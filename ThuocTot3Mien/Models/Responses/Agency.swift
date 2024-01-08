//
//  Agency.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 01/12/2023.
//

import Foundation

// MARK: - Agency

struct AgenciesData: Codable {
    let code: Int
    let message: [String?]
    let response: [Agency]
}

struct Agency: Codable {
    let id: Int
    let name: String
    let phoneNumber: String
    let address: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "ten_nha_thuoc"
        case phoneNumber = "sdt"
        case address = "dia_chi"
    }
}
