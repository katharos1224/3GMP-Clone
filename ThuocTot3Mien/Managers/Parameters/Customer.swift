//
//  Customer.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 02/12/2023.
//

import Foundation

// MARK: - Customer

struct Customer: Codable {
    let ten: String
    let id_agency: String
    let dia_chi: String
    let tinh: String
    let sdt: String
    let email: String
    let password: String
}
