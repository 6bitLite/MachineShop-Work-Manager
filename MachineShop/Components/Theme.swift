//
//  Theme.swift
//  Colors and status helpers shared by every screen.
//  MachineShop
//
//  Created by Mac-LAB on 10/19/26.
//

import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

enum Theme {
    /// Change this one line to put the shop's name on the login screen.
    static let appName = "Job Orders"

    // Surfaces
    static let background = Color.adaptive(light: 0xF1F3F5, dark: 0x101417)
    static let card       = Color.adaptive(light: 0xFFFFFF, dark: 0x1C2226)
    static let cardShadow = Color.black.opacity(0.07)

    // Text
    static let ink      = Color.adaptive(light: 0x151A1F, dark: 0xEDF0F2)
    static let mutedInk = Color.adaptive(light: 0x5B6770, dark: 0x9AA6AE)

    // Brand and status colors
    static let accent = Color.adaptive(light: 0x1B4FD6, dark: 0x6C95FF)   // Dykem blue
    static let amber  = Color.adaptive(light: 0xB8741A, dark: 0xE0A040)
    static let green  = Color.adaptive(light: 0x2A7F4F, dark: 0x4FBF82)
    static let danger = Color.adaptive(light: 0xC62828, dark: 0xFF7B7B)

    // Dark steel used for banners
    static let heroTop    = Color.adaptive(light: 0x1F2D3A, dark: 0x1A2733)
    static let heroBottom = Color.adaptive(light: 0x35597A, dark: 0x2B4A66)
    static let heroGradient = LinearGradient(
        colors: [heroTop, heroBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing)

    static func specialtyIcon(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("weld") { return "flame.fill" }
        if n.contains("torno") || n.contains("lathe") { return "gearshape.fill" }
        if n.contains("bor") { return "circle.circle.fill" }
        if n.contains("surfac") { return "square.stack.3d.up.fill" }
        return "wrench.and.screwdriver.fill"
    }

    static func statusColor(_ status: String) -> Color {
        switch status {
        case "done": return green
        case "in_progress": return accent
        default: return amber
        }
    }

    static func statusLabel(_ status: String) -> String {
        switch status {
        case "done": return "Done"
        case "in_progress": return "In progress"
        default: return "Waiting"
        }
    }
}
