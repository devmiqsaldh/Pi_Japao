import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var presenceStart = Date()
    @State private var presenceCutoff = Date()
    @State private var exitStart = Date()
    @State private var exitCutoff = Date()
    @State private var backendURL = ""
    @State private var isSaving = false
    @Environment(ErrorHandler.self) private var errorHandler

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .font(.title3)
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Servidor Backend")
                            .font(.headline)
                        TextField("http://192.168.1.100:8080", text: $backendURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
            } header: {
                Text("Conexão")
            } footer: {
                Text("Configure o endereço IP e porta do servidor onde o backend está rodando.")
            }
            
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .foregroundColor(AppTheme.accentColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horário de Início")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("", selection: $presenceStart, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppTheme.warningColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horário Limite")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("", selection: $presenceCutoff, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                }
            } header: {
                Text("Presença")
            } footer: {
                Text("Janela de tempo para registrar a presença dos alunos.")
            }
            
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "sunset.fill")
                            .foregroundColor(AppTheme.secondaryColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horário de Início")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("", selection: $exitStart, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppTheme.warningColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horário Limite")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("", selection: $exitCutoff, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                }
            } header: {
                Text("Saída")
            } footer: {
                Text("Janela de tempo para registrar a saída dos alunos.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppTheme.primaryColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email")
                                .font(.headline)
                            Text("Mensagens enviadas automaticamente")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "message.fill")
                            .foregroundColor(AppTheme.accentColor)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("WhatsApp")
                                .font(.headline)
                            Text("Mensagens enviadas automaticamente")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Notificações")
            } footer: {
                Text("As notificações são enviadas automaticamente por email e WhatsApp quando o sistema detecta presença, falta, saída ou não saída dos alunos.")
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
    }

    private func loadSettings() async {
        do {
            try await viewModel.loadSettings()
            if let s = viewModel.settings {
                presenceStart = s.presenceStart
                presenceCutoff = s.presenceCutoff
                exitStart = s.exitStart
                exitCutoff = s.exitCutoff
            }
        } catch {
            errorHandler.handleAPIError(error)
        }
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
        
        // Mensagens são fixas e gerenciadas pelo backend
        // Não precisam ser enviadas aqui, apenas horários
        do {
            try await viewModel.updateSettings(
                presenceStart: presenceStart,
                presenceCutoff: presenceCutoff,
                exitStart: exitStart,
                exitCutoff: exitCutoff,
                presenceMessage: nil, // Fixa no backend
                absenceMessage: nil, // Fixa no backend
                leftMessage: nil, // Fixa no backend
                notLeftMessage: nil // Fixa no backend
            )
            errorHandler.show("Configurações salvas com sucesso!", type: .success)
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
