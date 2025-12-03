import SwiftUI

struct AppTheme {
    // Cores principais
    static let primaryColor = Color(red: 0.2, green: 0.4, blue: 0.8) // Azul moderno
    static let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.2) // Vermelho/laranja
    static let accentColor = Color(red: 0.1, green: 0.7, blue: 0.5) // Verde
    
    // Cores de status
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red
    static let infoColor = Color.blue
    
    // Cores de fundo
    static let backgroundColor = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    // Gradientes
    static let primaryGradient = LinearGradient(
        colors: [primaryColor, primaryColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.primaryColor)
            .cornerRadius(12)
    }
}

