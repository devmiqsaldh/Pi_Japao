import SwiftUI

// Extensões para suporte adaptativo iPhone/iPad
extension View {
    func adaptivePadding() -> some View {
        self.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
    }
    
    func adaptiveMaxWidth() -> some View {
        self.frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : .infinity)
    }
}

struct AdaptiveStack<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            HStack {
                Spacer()
                content
                    .frame(maxWidth: 800)
                Spacer()
            }
        } else {
            content
        }
    }
}

