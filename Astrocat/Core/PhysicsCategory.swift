//
//  PhysicsCategory.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 09/05/26.
//

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let trap: UInt32 = 0x1 << 1
    static let platform: UInt32 = 0x1 << 2
    static let floor: UInt32 = 0x1 << 3
    static let finish: UInt32 = 0x1 << 4
}
