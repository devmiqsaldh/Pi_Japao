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
                TextField("Mensagem Presença", text: $presenceMessage, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Mensagem Falta", text: $absenceMessage, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Mensagem Saída", text: $leftMessage, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Mensagem Não Saiu", text: $notLeftMessage, axis: .vertical)
                    .lineLimit(3...6)
                Text("Use {name} e {time} como variáveis nos templates.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(AppTheme.primaryColor)
                    Text("Mensagens")
                }
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
            do {
                try await viewModel.loadSettings()
                if let s = viewModel.settings {
                    presenceStart = s.presenceStart
                    presenceCutoff = s.presenceCutoff
                    exitStart = s.exitStart
                    exitCutoff = s.exitCutoff
                    presenceMessage = s.presenceMessage
                    absenceMessage = s.absenceMessage
                    leftMessage = s.leftMessage
                    notLeftMessage = s.notLeftMessage
                }
            } catch {
                errorHandler.handleAPIError(error)
            }
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
        
        do {
            try await viewModel.updateSettings(
                presenceStart: presenceStart,
                presenceCutoff: presenceCutoff,
                exitStart: exitStart,
                exitCutoff: exitCutoff,
                presenceMessage: presenceMessage,
                absenceMessage: absenceMessage,
                leftMessage: leftMessage,
                notLeftMessage: notLeftMessage
            )
            errorHandler.show("Configurações salvas com sucesso!", type: .success)
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
