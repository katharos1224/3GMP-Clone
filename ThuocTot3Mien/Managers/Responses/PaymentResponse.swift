//
//  PaymentResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 25/12/2023.
//

import Foundation

// MARK: - COD

struct CODPaymentResponse: Codable {
    let code: Int
    let message: [String]
    let response: CODPayment?
}

struct CODPayment: Codable {
    let description: String
}

// MARK: - Online

struct OnlinePaymentResponse: Codable {
    let code: Int
    let message: [String]
    let response: OnlinePayment?
}

struct OnlinePayment: Codable {
    let description: String
    let urlPayment: String

    enum CodingKeys: String, CodingKey {
        case description
        case urlPayment = "url_payment"
    }
}
