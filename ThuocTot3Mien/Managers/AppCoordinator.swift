//
//  AppCoordinator.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Combine
import Foundation

class AppCoordinator {
    static let shared = AppCoordinator()

    private init() {}

    let completionPublisher = PassthroughSubject<Void, Never>()
}
