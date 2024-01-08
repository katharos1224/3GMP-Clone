//
//  DiscountResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 20/12/2023.
//

import Foundation

// MARK: - DiscountResponse

struct DiscountResponse: Codable {
    let code: Int
    let message: [String]
    let response: Discount?
}

// MARK: - Response

struct Discount: Codable {
    let voucherAvailable, coinAvailable, money: Int
    let voucherDescription, coinDescription: String

    enum CodingKeys: String, CodingKey {
        case voucherAvailable = "voucher_available"
        case coinAvailable = "coin_available"
        case money
        case voucherDescription = "voucher_description"
        case coinDescription = "coin_description"
    }
}
