import SwiftUI

struct IOS26FilledButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 44
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(themeManager.primaryButtonForeground)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.primaryButtonBackground)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct IOS26TintedButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 44
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(themeManager.secondaryButtonForeground)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.secondaryButtonBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(themeManager.tintedButtonBorder, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct IOS26DestructiveButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 44
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(themeManager.destructiveButtonForeground)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.destructiveButtonBackground)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct IOS26BorderedButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 36
    var foreground: Color? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(foreground ?? themeManager.primaryTextColor)
            .padding(.horizontal, 12)
            .frame(minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.subtleButtonBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(themeManager.separatorColor, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct IOS26CapsuleToggleStyle: ButtonStyle {
    let isSelected: Bool
    var selectedColor: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : themeManager.secondaryTextColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? selectedColor : themeManager.cardBackgroundColor)
            )
            .shadow(color: isSelected ? selectedColor.opacity(0.4) : themeManager.shadowColor, radius: isSelected ? 6 : 1, x: 0, y: isSelected ? 2 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == IOS26FilledButtonStyle {
    static var ios26Filled: IOS26FilledButtonStyle { IOS26FilledButtonStyle() }
}

extension ButtonStyle where Self == IOS26TintedButtonStyle {
    static var ios26Tinted: IOS26TintedButtonStyle { IOS26TintedButtonStyle() }
}

extension ButtonStyle where Self == IOS26DestructiveButtonStyle {
    static var ios26Destructive: IOS26DestructiveButtonStyle { IOS26DestructiveButtonStyle() }
}

extension ButtonStyle where Self == IOS26BorderedButtonStyle {
    static func ios26Bordered(foreground: Color? = nil) -> IOS26BorderedButtonStyle {
        IOS26BorderedButtonStyle(foreground: foreground)
    }
}

// Color-customizable filled style
struct IOS26FilledColorButtonStyle: ButtonStyle {
    var background: Color
    var foreground: Color = .white
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 44
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

