import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [AppSettings]

    @State private var presenceStart = Date()
    @State private var presenceCutoff = Date()
    @State private var exitStart = Date()
    @State private var exitCutoff = Date()

    @State private var presenceMessage = ""
    @State private var absenceMessage = ""
    @State private var leftMessage = ""
    @State private var notLeftMessage = ""

    var body: some View {
        let settings = settingsList.first

        Form {
            Section("Horários - Presença") {
                DatePicker("Início", selection: Binding(get: { presenceStart }, set: { presenceStart = $0 }), displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: Binding(get: { presenceCutoff }, set: { presenceCutoff = $0 }), displayedComponents: .hourAndMinute)
            }
            Section("Horários - Saída") {
                DatePicker("Início", selection: Binding(get: { exitStart }, set: { exitStart = $0 }), displayedComponents: .hourAndMinute)
                DatePicker("Limite", selection: Binding(get: { exitCutoff }, set: { exitCutoff = $0 }), displayedComponents: .hourAndMinute)
            }
            Section("Mensagens") {
                TextField("Mensagem Presença", text: $presenceMessage)
                TextField("Mensagem Falta", text: $absenceMessage)
                TextField("Mensagem Saída", text: $leftMessage)
                TextField("Mensagem Não Saiu", text: $notLeftMessage)
//                Text("Use {name} e {time} como variáveis.")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Configurações")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") { save() }
            }
        }
        .onAppear {
            if let s = settings {
                presenceStart = s.presenceStart
                presenceCutoff = s.presenceCutoff
                exitStart = s.exitStart
                exitCutoff = s.exitCutoff
                presenceMessage = s.presenceMessage
                absenceMessage = s.absenceMessage
                leftMessage = s.leftMessage
                notLeftMessage = s.notLeftMessage
            } else {
                let s = AppSettings.makeDefault()
                context.insert(s)
                try? context.save()
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

    private func save() {
        let s: AppSettings
        if let existing = settingsList.first {
            s = existing
        } else {
            s = AppSettings.makeDefault()
            context.insert(s)
        }
        s.presenceStart = presenceStart
        s.presenceCutoff = presenceCutoff
        s.exitStart = exitStart
        s.exitCutoff = exitCutoff
        s.presenceMessage = presenceMessage
        s.absenceMessage = absenceMessage
        s.leftMessage = leftMessage
        s.notLeftMessage = notLeftMessage

        try? context.save()
    }
}

#Preview("SettingsView Preview - Empty") {
    SettingsView()
        .modelContainer(for: [
            Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self
        ], inMemory: true)
}

#Preview("SettingsView Preview - With Defaults") {
    let container = try! ModelContainer(for: Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    context.insert(AppSettings.makeDefault())
    return SettingsView()
        .modelContainer(container)
}
