//
//  ProfileResponse.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Foundation

// Response
struct ProfileResponse: Codable {
    let code: Int
    let message: [String]
    let response: MemberData?
}

// Member Data
struct MemberData: Codable {
    let ten: String
    let tenNhaThuoc: String?
    let diaChi: String
    let email: String?
    let sdt: String
    let tinh: Int
    let maSoThue: String?
    let img: String?
    let trangThai: Int
    let provinces: [Province]
    let thuHang: String
    let thuHangIcon: String?
    let coins: Int
    let description: String

    enum CodingKeys: String, CodingKey {
        case ten
        case tenNhaThuoc = "ten_nha_thuoc"
        case diaChi = "dia_chi"
        case email
        case sdt
        case tinh
        case maSoThue = "ma_so_thue"
        case img
        case trangThai = "trang_thai"
        case provinces
        case thuHang = "thu_hang"
        case thuHangIcon = "thu_hang_icon"
        case coins
        case description
    }
}

struct UpdatedProfileResponse: Codable {
    let code: Int
    let message: [String]
    let response: UpdatedMemberData?
}

struct UpdatedMemberData: Codable {
    let ten: String
    let tenNhaThuoc: String?
    let diaChi: String
    let email: String?
    let sdt: String
    let tinh: Int
    let img: String?
    let trangThai: Int
    let provinces: [Province]
    let description: String

    enum CodingKeys: String, CodingKey {
        case ten
        case tenNhaThuoc = "ten_nha_thuoc"
        case diaChi = "dia_chi"
        case email
        case sdt
        case tinh
        case img
        case trangThai = "trang_thai"
        case provinces
        case description
    }
}
