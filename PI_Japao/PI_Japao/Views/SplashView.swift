import SwiftUI

struct SplashView: View {
    @Environment(AttendanceManager.self) private var attendanceManager
    @Environment(ErrorHandler.self) private var errorHandler
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Fundo gradiente
            LinearGradient(
                colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.opacity(0.8),
                    AppTheme.secondaryColor.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/Ícone
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)
                    
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // Nome do App
                Text("PI_Japão")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // Subtítulo
                Text("Sistema de Presença Escolar")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Aguardar 2 segundos antes de mostrar o conteúdo principal
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
                .environment(attendanceManager)
                .environment(errorHandler)
        }
    }
}

#Preview {
    SplashView()
}

