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

    var API_VERSION: String {
        return apiVersion
    }

    private var baseUrl: String = ""
    private var apiVersion: String = ""

    init() {
        baseUrl = "http://18.138.176.213/"
        apiVersion = "api/v2/"
    }
}
