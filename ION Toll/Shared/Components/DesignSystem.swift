import SwiftUI
import AuthenticationServices

// MARK: - Design Tokens

enum IONDesign {
    // MARK: Colors
    enum Color {
        static let brandPrimary = SwiftUI.Color(red: 0x4E / 255, green: 0x10 / 255, blue: 0x90 / 255)
        static let brandLight = SwiftUI.Color(red: 0x6B / 255, green: 0x33 / 255, blue: 0xB0 / 255)
        static let brandSurface = SwiftUI.Color(red: 0xF5 / 255, green: 0xF0 / 255, blue: 0xFA / 255)
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let pill: CGFloat = 100
    }

    // MARK: Sizing
    enum Sizing {
        static let buttonHeight: CGFloat = 50
    }

    // MARK: Brand Gradient
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [IONDesign.Color.brandPrimary, IONDesign.Color.brandLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Font Extensions

extension Font {
    static func ion(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold: fontName = "Geist-Bold"
        case .semibold: fontName = "Geist-SemiBold"
        case .medium: fontName = "Geist-Medium"
        default: fontName = "Geist-Regular"
        }
        return .custom(fontName, size: size)
    }

    static func ionBold(_ size: CGFloat) -> Font {
        .custom("Geist-Bold", size: size)
    }

    // Semantic shortcuts
    static let ionLargeTitle = Font.ionBold(28)
    static let ionTitle = Font.ionBold(24)
    static let ionTitle2 = Font.ionBold(22)
    static let ionTitle3 = Font.ionBold(20)
    static let ionHeadline = Font.ionBold(16)
    static let ionBody = Font.ion(14)
    static let ionCallout = Font.ion(13)
    static let ionSubheadline = Font.ion(14)
    static let ionFootnote = Font.ion(12)
    static let ionCaption = Font.ion(11)
}

// MARK: - Color Convenience (top-level SwiftUI.Color extension)

extension SwiftUI.Color {
    static let brandPrimary = IONDesign.Color.brandPrimary
    static let brandLight = IONDesign.Color.brandLight
    static let brandSurface = IONDesign.Color.brandSurface
}

// MARK: - Reusable: Primary Button (Filled)

struct IONPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.ion(14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: IONDesign.Sizing.buttonHeight)
            .background(
                isEnabled
                    ? IONDesign.Color.brandPrimary
                    : IONDesign.Color.brandPrimary.opacity(0.4),
                in: .rect(cornerRadius: IONDesign.Radius.md)
            )
        }
        .buttonStyle(.pressScale)
        .disabled(isDisabled || isLoading)
        .animation(.spring(duration: 0.3), value: isDisabled)
    }

    private var isEnabled: Bool { !isDisabled && !isLoading }
}

// MARK: - Reusable: Secondary Button (Outlined)

struct IONSecondaryButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void

    init(_ title: String, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.ion(14, weight: .semibold))
                .foregroundStyle(SwiftUI.Color.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: IONDesign.Sizing.buttonHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: IONDesign.Radius.md)
                        .stroke(
                            isDisabled
                                ? SwiftUI.Color.brandPrimary.opacity(0.4)
                                : SwiftUI.Color.brandPrimary,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.pressScale)
        .disabled(isDisabled)
        .animation(.spring(duration: 0.3), value: isDisabled)
    }
}

// MARK: - Reusable: Ghost Button (Text Only)

struct IONGhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.pressScale)
    }
}

// MARK: - Reusable: Text Field

struct IONTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var prefix: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false
    var isRequired: Bool = false
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil
    var errorMessage: String? = nil

    @FocusState.Binding private var isFocused: Bool
    @State private var isPasswordVisible = false

    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isRequired: Bool = false,
        prefix: String? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        isSecure: Bool = false,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil,
        errorMessage: String? = nil,
        isFocused: FocusState<Bool>.Binding
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.prefix = prefix
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.isSecure = isSecure
        self.isRequired = isRequired
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.errorMessage = errorMessage
        self._isFocused = isFocused
    }

    var body: some View {
        VStack(alignment: .leading, spacing: IONDesign.Spacing.sm) {
            (Text(title)
                .font(.ionCaption)
                .foregroundStyle(.secondary)
            + (isRequired ? Text(" *").font(.ionCaption).foregroundStyle(.red) : Text("")))

            HStack(spacing: 12) {
                if let prefix {
                    Text(prefix)
                        .font(.ionBody)
                        .foregroundStyle(.secondary)
                }

                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                        .submitLabel(submitLabel)
                        .onSubmit { onSubmit?() }
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                        .submitLabel(submitLabel)
                        .onSubmit { onSubmit?() }
                }

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.ionBody)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: IONDesign.Radius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .animation(.easeInOut(duration: 0.2), value: errorMessage)

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.ionFootnote)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    private var borderColor: SwiftUI.Color {
        if let errorMessage, !errorMessage.isEmpty {
            return .red
        }
        return isFocused ? Color.brandPrimary : Color.secondary.opacity(0.3)
    }
}

// MARK: - Reusable: Error Banner

struct IONErrorBanner: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.ionFootnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

// MARK: - Reusable: Section Header

struct IONSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.ionHeadline)
            .foregroundStyle(.primary)
    }
}

// MARK: - Reusable: Divider with Text ("Atau")

struct IONOrDivider: View {
    let text: String

    init(_ text: String = "Atau") {
        self.text = text
    }

    var body: some View {
        HStack(spacing: IONDesign.Spacing.lg) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)

            Text(text)
                .font(.ionSubheadline)
                .foregroundStyle(.secondary)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Reusable: Toast

struct IONToast: View {
    enum Style {
        case error
        case info
        case success
        case warning
    }

    let message: String
    let style: Style
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(minWidth: 240, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
        .onTapGesture {
            onDismiss()
        }
    }

    private var iconName: String {
        switch style {
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: SwiftUI.Color {
        switch style {
        case .error: return .red
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        }
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @State private var isInserted = false
    @Binding var isPresented: Bool
    let message: String
    let style: IONToast.Style

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    IONToast(message: message, style: style) {
                        withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                            isPresented = false
                        }
                    }
                    .padding(.top, 8)
                    .scaleEffect(isInserted ? 1 : 0.6, anchor: .top)
                    .opacity(isInserted ? 1 : 0)
                    .offset(y: isInserted ? 0 : -10)
                    .onAppear {
                        withAnimation(.spring(duration: 0.5, bounce: 0.18)) {
                            isInserted = true
                        }
                    }
                    .onDisappear {
                        isInserted = false
                    }
                }
            }
    }
}

extension View {
    func ionToast(isPresented: Binding<Bool>, message: String, style: IONToast.Style = .info) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, style: style))
    }
}

// MARK: - Error Helpers

extension Error {
    var isUserCancellation: Bool {
        if self is CancellationError { return true }
        if let authError = self as? ASAuthorizationError,
           authError.code == .canceled { return true }
        let nsError = self as NSError
        if nsError.domain == "com.google.GIDSignIn",
           nsError.code == -5 { return true }
        return false
    }
}
