import SwiftUI

// MARK: - Color System
// 暖调案卷风色彩系统

enum DetectiveColors {
    /// 全局奶油底色 — 模拟旧案卷纸张
    static let warmBackground = Color(hex: "FFFBEB")
    /// 主文字色 — 钢笔墨水质感
    static let ink = Color(hex: "44403C")
    /// 重点/奖励/悬赏令 — 琥珀金
    static let accent = Color(hex: "D97706")
    /// 琥珀金浅底
    static let accentLight = Color(hex: "FEF3C7")
    /// 完成状态/正确反馈 — 松石绿
    static let success = Color(hex: "65A30D")
    /// 紧迫提示/错误（克制使用）— 暖红
    static let danger = Color(hex: "DC2626")
    /// 白色卡片
    static let paper = Color.white
    /// 次级背景/分隔区 — 浅米色
    static let muted = Color(hex: "F5F0E8")
    /// 卡片边框/分割线
    static let border = Color(hex: "E7E0D5")
    /// 辅助文字 — 浅灰棕
    static let textMuted = Color(hex: "A8A29E")
    /// 次级文字
    static let textSecondary = Color(hex: "78716C")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Typography
// Fredoka (标题) + Nunito (正文)

enum DetectiveTypography {
    static let titleLarge = Font.custom("Fredoka-Bold", size: 32)
    static let titleMedium = Font.custom("Fredoka-SemiBold", size: 20)
    static let titleSmall = Font.custom("Fredoka-SemiBold", size: 16)
    static let body = Font.custom("Nunito-Regular", size: 14)
    static let bodySmall = Font.custom("Nunito-Regular", size: 11)
    static let label = Font.custom("Nunito-Bold", size: 10)
}

// MARK: - Spacing & Radius

enum DetectiveRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 18
}

enum DetectiveSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
}

// MARK: - Shared Card Style

extension View {
    func cardStyle() -> some View {
        self
            .background(DetectiveColors.paper)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.large)
                    .stroke(DetectiveColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
