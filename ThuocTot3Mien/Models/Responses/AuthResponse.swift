//
//  AuthResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 02/12/2023.
//

import Foundation

// MARK: - Description

struct Description: Codable {
    let description: String
}

// MARK: - Pharmacy Response

// Pharmacy Register
struct PharmacyRegisterResponse: Codable {
    let code: Int
    let message: [String]
    let response: Description?
}

// Pharmacy Login
struct PharmacyLoginResponse: Codable {
    let code: Int
    let message: [String]
    let response: PharmacyLoginResponseBody?
}

struct PharmacyLoginResponseBody: Codable {
    let id: Int
    let name: String
    let pharmacy: String
    let phoneNumber: String
    let email: String
    let address: String
    let taxCode: String?
    let status: Int
    let token: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "ten"
        case pharmacy = "ten_nha_thuoc"
        case phoneNumber = "sdt"
        case email
        case address = "dia_chi"
        case taxCode = "ma_so_thue"
        case status = "trang_thai"
        case token
        case description
    }
}

// MARK: - Customer Response

// Customer Register
struct CustomerRegisterResponse: Codable {
    let code: Int
    let message: [String]
    let response: Description?
}

// Customer Login
struct CustomerLoginResponse: Codable {
    let code: Int
    let message: [String]
    let response: CustomerLoginResponseBody?
}

struct CustomerLoginResponseBody: Codable {
    let id: Int
    let idAgency: Int
    let name: String
    let phoneNumber: String
    let email: String
    let address: String
    let taxCode: String?
    let status: Int
    let agency: Int
    let token: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case idAgency = "id_agency"
        case name = "ten"
        case phoneNumber = "sdt"
        case email
        case address = "dia_chi"
        case taxCode = "ma_so_thue"
        case status = "trang_thai"
        case agency
        case token
        case description
    }
}
