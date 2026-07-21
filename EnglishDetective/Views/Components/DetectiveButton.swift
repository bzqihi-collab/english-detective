import SwiftUI

// MARK: - Themed Button Component

struct DetectiveButton: View {
    enum ButtonStyle {
        /// 深棕实心 — 最重操作（受理案件、开始调查）
        case primary
        /// 白底描边 — 次要操作（冷案档案、设置）
        case secondary
        /// 琥珀实心 — 强调操作（提交报告、追查）
        case accent

        var bgColor: Color {
            switch self {
            case .primary: return DetectiveColors.ink
            case .secondary: return DetectiveColors.paper
            case .accent: return DetectiveColors.accent
            }
        }

        var fgColor: Color {
            switch self {
            case .primary, .accent: return .white
            case .secondary: return DetectiveColors.ink
            }
        }

        var borderColor: Color {
            self == .secondary ? DetectiveColors.border : .clear
        }

        var borderWidth: CGFloat {
            self == .secondary ? 1.5 : 0
        }
    }

    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    var fullWidth: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Text(icon)
                }
                Text(title)
                    .fontWeight(.bold)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(style.bgColor)
            .foregroundColor(style.fgColor)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.small)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .scaleEffectOnPress()
    }
}

// MARK: - Press Animation Modifier

extension View {
    func scaleEffectOnPress() -> some View {
        self.modifier(PressScaleModifier())
    }
}

struct PressScaleModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                                pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        DetectiveButton(title: "受理新案件", icon: "📁", style: .primary) {}
        DetectiveButton(title: "冷案档案室", icon: "📂", style: .secondary) {}
        DetectiveButton(title: "提交报告", icon: "📋", style: .accent) {}
        DetectiveButton(title: "清理冷案", icon: "📂", style: .accent, fullWidth: false) {}
    }
    .padding()
    .background(DetectiveColors.warmBackground)
}
