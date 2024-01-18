//
//  Config.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 17/01/2024.
//

import Foundation

class Config {
    static let shared = Config()

    var BASE_API_URL: String {
        return baseUrl
    }

    private var baseUrl: String = ""

    init() {
        baseUrl = "http://18.138.176.213/api/v2/"
    }
}
