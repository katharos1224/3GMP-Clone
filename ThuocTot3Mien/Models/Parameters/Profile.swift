//
//  Profile.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Foundation

struct Profile: Codable {
    let ten: String
    let ten_nha_thuoc: String
    let dia_chi: String
    let tinh: String
    let ma_so_thue: String?
    let email: String?
    let password: String?
}
