import SwiftUI

enum FontName {
    static let martianMonoBold = "MartianMono-SemiExpandedRegular_Bold"
    static let martianMonoLight = "MartianMono-SemiExpandedRegular_Light"
    static let martianMonoExtraLight = "MartianMono-SemiExpandedRegular_ExtraLight"
}


struct DottedFieldContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundColor(.gray)
            )
    }
}


extension View {
    func dottedFieldStyle() -> some View {
        self.modifier(DottedFieldContainer())
    }
    /// Title: Bold, 11pt, 100% black
    func titleFont() -> some View {
        self.font(.custom(FontName.martianMonoBold, size: 11))
            .foregroundColor(Color.black.opacity(1.0))
    }

    /// Subtitle: Light, 11pt, 70% black
    func subtitleFont() -> some View {
        self.font(.custom(FontName.martianMonoLight, size: 11))
            .foregroundColor(Color.black.opacity(0.7))
    }

    /// Label: ExtraLight, 11pt, 70% black
    func labelFont() -> some View {
        self.font(.custom(FontName.martianMonoExtraLight, size: 11))
            .foregroundColor(Color.black.opacity(0.7))
    }
}



struct DreamStyleColors {
    static func color(for style: Int) -> Color {
        switch style {
        case 1:
            return Color(#colorLiteral(red: 0.847, green: 1.0, blue: 0.6, alpha: 1.0)) // 浅绿 Move to NYC
        case 2:
            return Color(#colorLiteral(red: 0.75, green: 0.95, blue: 1.0, alpha: 1.0)) // 浅蓝 Home Vlogger
        case 3:
            return Color(#colorLiteral(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)) // 橘红 Publish my App
        case 4:
            return Color(#colorLiteral(red: 0.9, green: 0.8, blue: 1.0, alpha: 1.0)) // 淡紫 Social
        case 5:
            return Color(#colorLiteral(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)) // 柠檬黄 Get Promoted
        default:
            return Color.gray.opacity(0.3)
        }
    }
}
