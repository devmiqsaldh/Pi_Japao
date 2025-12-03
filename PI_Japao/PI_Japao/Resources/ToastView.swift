import SwiftUI

struct Toast: ViewModifier {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    
    enum ToastType {
        case error
        case success
        case warning
        case info
        
        var color: Color {
            switch self {
            case .error: return AppTheme.errorColor
            case .success: return AppTheme.successColor
            case .warning: return AppTheme.warningColor
            case .info: return AppTheme.infoColor
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isPresented {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: type.icon)
                            .foregroundColor(.white)
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(type.color)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(1000)
            }
        }
    }
}

extension View {
    func toast(message: String, type: Toast.ToastType, isPresented: Binding<Bool>) -> some View {
        modifier(Toast(message: message, type: type, isPresented: isPresented))
    }
}

