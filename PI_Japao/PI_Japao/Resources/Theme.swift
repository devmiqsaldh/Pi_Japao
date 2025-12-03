import SwiftUI

struct AppTheme {
    // Cores principais - Identidade Visual Branco e Vermelho
    static let primaryColor = Color(red: 0.85, green: 0.0, blue: 0.15) // Vermelho principal (#D90026)
    static let secondaryColor = Color(red: 0.95, green: 0.95, blue: 0.95) // Branco suave
    static let accentColor = Color(red: 0.7, green: 0.0, blue: 0.1) // Vermelho escuro
    
    // Cores de status
    static let successColor = Color(red: 0.0, green: 0.6, blue: 0.3) // Verde sucesso
    static let warningColor = Color(red: 1.0, green: 0.6, blue: 0.0) // Laranja aviso
    static let errorColor = Color(red: 0.9, green: 0.2, blue: 0.2) // Vermelho erro
    static let infoColor = Color(red: 0.2, green: 0.5, blue: 0.9) // Azul info
    
    // Cores de fundo
    static let backgroundColor = Color.white // Branco puro
    static let cardBackground = Color.white // Branco para cards
    static let secondaryBackground = Color(red: 0.98, green: 0.98, blue: 0.98) // Branco quase puro
    
    // Cores de texto
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Quase preto
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5) // Cinza
    
    // Gradientes
    static let primaryGradient = LinearGradient(
        colors: [primaryColor, accentColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color.white, secondaryBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Tipografia
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppTheme.primaryColor.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.primaryColor.opacity(0.1), lineWidth: 1)
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.primaryColor)
            .cornerRadius(12)
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(AppTheme.primaryColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.primaryColor, lineWidth: 2)
            )
    }
}

