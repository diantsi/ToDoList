//
//  Date.swift
//  ToDo
//
//  Created by Діана Цісарук on 31.10.2026.
//

import Foundation

extension Date {
    var voiceOverFormatted: String {
        let calendar = Calendar.current

        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)

        return """
        \(day) числа \(month) місяця \(year) року о \(hour) годині \(minute) хвилин
        """
    }
}
