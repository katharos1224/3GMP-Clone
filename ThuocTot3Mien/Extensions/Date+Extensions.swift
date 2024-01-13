//
//  Date+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 09/01/2024.
//

import Foundation

extension Date {
    func convertToString(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
