//
//  VoucherResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 19/12/2023.
//

import Foundation

// MARK: - Voucher

struct VoucherResponse: Codable {
    let code: Int
    let message: [String]
    let response: [Voucher]?
}

// MARK: - VoucherResponse

struct Voucher: Codable {
    let id: Int
    let title, value, content: String
}
