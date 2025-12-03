import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var presenceStart = Date()
    @State private var presenceCutoff = Date()
    @State private var exitStart = Date()
    @State private var exitCutoff = Date()
    @State private var presenceMessage = ""
    @State private var absenceMessage = ""
    @State private var leftMessage = ""
    @State private var notLeftMessage = ""
    @State private var backendURL = ""
    @State private var isSaving = false
    @State private var showSuccessAlert = false
    @Environment(ErrorHandler.self) private var errorHandler

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "server.rack")
                        .foregroundColor(AppTheme.primaryColor)
                    Text("URL do Backend")
                }
                TextField("http://192.168.1.100:8080", text: $backendURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                Text("Configure o IP e porta do servidor backend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Conexão")
            }
            
            Section {
                DatePicker("Início", selection: $presenceStart, displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: $presenceCutoff, displayedComponents: .hourAndMinute)
            } header: {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(AppTheme.accentColor)
                    Text("Horários - Presença")
                }
            }
            
            Section {
                DatePicker("Início", selection: $exitStart, displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: $exitCutoff, displayedComponents: .hourAndMinute)
            } header: {
                HStack {
                    Image(systemName: "sunset.fill")
                        .foregroundColor(AppTheme.secondaryColor)
                    Text("Horários - Saída")
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mensagem de Presença")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Ex: {name} - Presença confirmada", text: $presenceMessage, axis: .vertical)
                        .lineLimit(2...4)
                        .textInputAutocapitalization(.sentences)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mensagem de Falta")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Ex: {name} - Falta registrada", text: $absenceMessage, axis: .vertical)
                        .lineLimit(2...4)
                        .textInputAutocapitalization(.sentences)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mensagem de Saída")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Ex: {name} - Saída confirmada", text: $leftMessage, axis: .vertical)
                        .lineLimit(2...4)
                        .textInputAutocapitalization(.sentences)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mensagem de Não Saiu")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Ex: {name} - Não saiu", text: $notLeftMessage, axis: .vertical)
                        .lineLimit(2...4)
                        .textInputAutocapitalization(.sentences)
                }
                
                Text("Use {name} para o nome do aluno. As mensagens são salvas e permanecem até serem alteradas.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } header: {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    Text("Mensagens de Notificação")
                }
            } footer: {
                Text("As mensagens são enviadas por email quando o sistema detecta presença, falta, saída ou não saída do aluno.")
            }
            
        }
        .navigationTitle("Configurações")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await save()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Salvar")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isSaving)
            }
        }
        .task {
            backendURL = AppConfig.shared.backendURL
            await loadSettings()
        }
        .onAppear {
            // Garantir que sempre tenha valores padrão se não carregou ainda
            if presenceMessage.isEmpty {
                presenceMessage = "{name} - Presença confirmada"
            }
            if absenceMessage.isEmpty {
                absenceMessage = "{name} - Falta registrada"
            }
            if leftMessage.isEmpty {
                leftMessage = "{name} - Saída confirmada"
            }
            if notLeftMessage.isEmpty {
                notLeftMessage = "{name} - Não saiu"
            }
        }
    }

    private func loadSettings() async {
        do {
            try await viewModel.loadSettings()
            if let s = viewModel.settings {
                presenceStart = s.presenceStart
                presenceCutoff = s.presenceCutoff
                exitStart = s.exitStart
                exitCutoff = s.exitCutoff
                // Garantir que mensagens sempre tenham valores
                presenceMessage = s.presenceMessage.isEmpty ? "{name} - Presença confirmada" : s.presenceMessage
                absenceMessage = s.absenceMessage.isEmpty ? "{name} - Falta registrada" : s.absenceMessage
                leftMessage = s.leftMessage.isEmpty ? "{name} - Saída confirmada" : s.leftMessage
                notLeftMessage = s.notLeftMessage.isEmpty ? "{name} - Não saiu" : s.notLeftMessage
            } else {
                // Se não houver configurações, usar valores padrão
                setDefaultMessages()
            }
        } catch {
            // Se houver erro ao carregar, usar valores padrão
            setDefaultMessages()
            errorHandler.handleAPIError(error)
        }
    }
    
    private func setDefaultMessages() {
        presenceMessage = "{name} - Presença confirmada"
        absenceMessage = "{name} - Falta registrada"
        leftMessage = "{name} - Saída confirmada"
        notLeftMessage = "{name} - Não saiu"
    }
    
    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
        // Salvar URL do backend
        if !backendURL.isEmpty {
            let trimmedURL = backendURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedURL.isEmpty {
                AppConfig.shared.backendURL = trimmedURL
            }
        }
        
        // Garantir que mensagens não estejam vazias (usar padrão se necessário)
        let finalPresenceMessage = presenceMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            ? "{name} - Presença confirmada" 
            : presenceMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalAbsenceMessage = absenceMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            ? "{name} - Falta registrada" 
            : absenceMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalLeftMessage = leftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            ? "{name} - Saída confirmada" 
            : leftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNotLeftMessage = notLeftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            ? "{name} - Não saiu" 
            : notLeftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await viewModel.updateSettings(
                presenceStart: presenceStart,
                presenceCutoff: presenceCutoff,
                exitStart: exitStart,
                exitCutoff: exitCutoff,
                presenceMessage: finalPresenceMessage,
                absenceMessage: finalAbsenceMessage,
                leftMessage: finalLeftMessage,
                notLeftMessage: finalNotLeftMessage
            )
            errorHandler.show("Configurações salvas com sucesso!", type: .success)
            // Recarregar para garantir sincronização
            await loadSettings()
        } catch {
            errorHandler.handleAPIError(error)
        }
    }
}

#Preview("SettingsView") {
    NavigationStack {
        SettingsView()
    }
}

#Preview("SettingsView - With Data") {
    let viewModel = SettingsViewModel()
    let settings = AppSettingsDTO(
        id: UUID(),
        presenceStart: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
        presenceCutoff: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!,
        exitStart: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!,
        exitCutoff: Calendar.current.date(bySettingHour: 17, minute: 30, second: 0, of: Date())!,
        presenceMessage: "Presença registrada para {name} às {time}.",
        absenceMessage: "Falta registrada para {name}.",
        leftMessage: "Saída registrada para {name} às {time}.",
        notLeftMessage: "Não saiu registrado para {name}.",
        createdAt: Date(),
        updatedAt: Date()
    )
    viewModel.settings = settings
    return NavigationStack {
        SettingsView()
    }
}
