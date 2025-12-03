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
    @State private var isSaving = false

    var body: some View {
        Form {
            Section("Horários - Presença") {
                DatePicker("Início", selection: $presenceStart, displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: $presenceCutoff, displayedComponents: .hourAndMinute)
            }
            Section("Horários - Saída") {
                DatePicker("Início", selection: $exitStart, displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: $exitCutoff, displayedComponents: .hourAndMinute)
            }
            Section("Mensagens") {
                TextField("Mensagem Presença", text: $presenceMessage)
                TextField("Mensagem Falta", text: $absenceMessage)
                TextField("Mensagem Saída", text: $leftMessage)
                TextField("Mensagem Não Saiu", text: $notLeftMessage)
                Text("Use {name} e {time} como variáveis.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Configurações")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    Task {
                        await save()
                    }
                }
                .disabled(isSaving)
            }
        }
        .task {
            await viewModel.loadSettings()
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
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
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
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
    }
}
