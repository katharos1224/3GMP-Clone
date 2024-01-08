//
//  Payment.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 25/12/2023.
//

import Foundation

struct Payment: Codable {
    let dataId: [Int]
    let device: Int
    let ten: String
    let sdt: String
    let email: String?
    let diaChi: String
    let maSoThue: String?
    let ghiChu: String?
    let ckTruoc: Int
    let voucher: String?
    let coin: Int
    let totalPrice: String

    enum CodingKeys: String, CodingKey {
        case dataId = "data_id[]"
        case device
        case ten
        case sdt
        case email
        case diaChi = "dia_chi"
        case maSoThue = "ma_so_thue"
        case ghiChu = "ghi_chu"
        case ckTruoc = "ck_truoc"
        case voucher
        case coin
        case totalPrice = "total_price"
    }
}
