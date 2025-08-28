//
//  DateOnly.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import Foundation

struct DateOnly: Hashable, Comparable {
    let y: Int; let m: Int; let d: Int
    var date: Date {
        let c = DateComponents(year: y, month: m, day: d)
        return Calendar.current.date(from: c) ?? Date()
    }
    init(from date: Date) {
        let c = Calendar.current.dateComponents([.year,.month,.day], from: date)
        y = c.year ?? 0; m = c.month ?? 0; d = c.day ?? 0
    }
    static func < (lhs: DateOnly, rhs: DateOnly) -> Bool {
        if lhs.y != rhs.y { return lhs.y < rhs.y }
        if lhs.m != rhs.m { return lhs.m < rhs.m }
        return lhs.d < rhs.d
    }
}
