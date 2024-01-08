//
//  Platform.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 25/12/2023.
//

import Foundation

enum Platform {
    case iOS
    case android
}

enum PlatformManager {
    static func getPlatform() -> Int {
        #if targetEnvironment(simulator)
            return 0
        #elseif targetEnvironment(macCatalyst)
            return 0
        #elseif os(iOS)
            return 0
        #elseif os(watchOS)
            return 0
        #elseif os(tvOS)
            return 0
        #elseif os(macOS)
            return 0
        #else
            return 1
        #endif
    }
}
