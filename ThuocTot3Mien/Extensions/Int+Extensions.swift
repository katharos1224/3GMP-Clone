//
//  Int+Extensions.swift
//  MenuVNC2
//
//  Created by Katharos on 29/11/2023.
//

import Foundation

extension Int {
    func formattedWithSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        if let formattedNumber = numberFormatter.string(from: NSNumber(value: self)) {
            return formattedNumber
        }

        return "\(self)"
    }
}
