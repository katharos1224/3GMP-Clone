//
//  ShowProductResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import Foundation

struct ShowProductResponse: Codable {
    let code: Int
    let message: [String]
    let response: Description?
}
