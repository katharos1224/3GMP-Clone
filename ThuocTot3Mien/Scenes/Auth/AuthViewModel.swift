//
//  AuthViewModel.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 02/12/2023.
//

import Combine
import Foundation

class AuthViewModel {
    var isCustomer: Bool = true
    var isPasswordVisible = false

    var updateUI: (() -> Void)?
    var showResponseMessage: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?

    func login(username: String, password: String) -> AnyPublisher<Bool, Never> {
        return isCustomer
            ? loginCustomerPublisher(username: username, password: password)
            : loginPublisher(username: username, password: password)

        func loginPublisher(username: String, password: String) -> AnyPublisher<Bool, Never> {
            return Future<Bool, Never> { promise in
                NetworkManager.shared.login(username: username, password: password) { result in
                    switch result {
                    case let .success(result):
                        print(result)
                        promise(.success(result.response == nil ? false : true))

                        if result.response == nil {
                            let message = result.message
                            let messageString = message.joined(separator: "\n")
                            self.showResponseMessage?(messageString)
                        } else {
                            guard let token = result.response?.token else { return }
                            KeychainService.saveToken(token: token)
                            self.updateUI?()
                        }
                    case .failure:
                        promise(.success(false))
                    }
                }
            }
            .eraseToAnyPublisher()
        }

        func loginCustomerPublisher(username: String, password: String) -> AnyPublisher<Bool, Never> {
            return Future<Bool, Never> { promise in
                self.showLoading?(false)

                NetworkManager.shared.loginCustomer(username: username, password: password) { result in
                    switch result {
                    case let .success(result):
                        promise(.success(result.response == nil ? false : true))

                        if result.response == nil {
                            let message = result.message
                            let messageString = message.joined(separator: "\n")
                            self.showResponseMessage?(messageString)
                        } else {
                            guard let token = result.response?.token else { return }
                            KeychainService.saveToken(token: token)
                            self.updateUI?()

                            guard let name = result.response?.name, let phone = result.response?.phoneNumber, let address = result.response?.address, let email = result.response?.email else { return }
                            UserDefaults.standard.set(name, forKey: "name")
                            UserDefaults.standard.set(phone, forKey: "phone")
                            UserDefaults.standard.set(address, forKey: "address")
                            UserDefaults.standard.set(email, forKey: "email")
                        }
                    case .failure:
                        promise(.success(false))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    func registerPharmacy(pharmacy: Pharmacy, imageData: Data) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            NetworkManager.shared.register(registerRequest: pharmacy, fileData: imageData) { [weak self] result in
                self?.showLoading?(false)

                switch result {
                case let .success(result):
                    promise(.success(result.response == nil ? false : true))

                    if result.response == nil {
                        let message = result.message
                        let messageString = message.joined(separator: "\n")
                        self?.showResponseMessage?(messageString)
                    } else {
                        self?.updateUI?()
                    }
                case .failure:
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func registerCustomer(customer: Customer, imageData: Data) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            NetworkManager.shared.registerCustomer(registerRequest: customer, fileData: imageData) { [weak self] result in
                self?.showLoading?(false)

                switch result {
                case let .success(result):
                    promise(.success(result.response == nil ? false : true))

                    if result.response == nil {
                        let message = result.message
                        let messageString = message.joined(separator: "\n")
                        self?.showResponseMessage?(messageString)
                    } else {
                        self?.updateUI?()
                    }
                case .failure:
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
}
