import SwiftUI
import SwiftData

struct BeaconsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Beacon.name, order: .forward, animation: .default)
    private var beacons: [Beacon]

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(beacons) { beacon in
                    NavigationLink {
                        BeaconFormView(beacon: beacon)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(beacon.name)
                            Text("ID: \(beacon.id)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let email = beacon.email, !email.isEmpty {
                                Text("Email: \(email)").font(.caption2)
                            }
                            if let phone = beacon.phone, !phone.isEmpty {
                                Text("Telefone: \(phone)").font(.caption2)
                            }
                            Toggle("Ativo", isOn: Binding(
                                get: { beacon.isActive },
                                set: { new in
                                    beacon.isActive = new
                                    try? context.save()
                                }
                            ))
                            .toggleStyle(.switch)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Beacons")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Adicionar", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    BeaconFormView()
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            context.delete(beacons[idx])
        }
        try? context.save()
    }
}

struct BeaconFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State var id: String = ""
    @State var name: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var isActive: Bool = true

    var beacon: Beacon?

    init(beacon: Beacon? = nil) {
        self.beacon = beacon
        if let b = beacon {
            _id = State(initialValue: b.id)
            _name = State(initialValue: b.name)
            _email = State(initialValue: b.email ?? "")
            _phone = State(initialValue: b.phone ?? "")
            _isActive = State(initialValue: b.isActive)
        }
    }

    var body: some View {
        Form {
            Section("Identificação") {
                TextField("ID do Beacon", text: $id)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Nome", text: $name)
            }
            Section("Contato") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Telefone", text: $phone)
                    .keyboardType(.phonePad)
            }
            Section {
                Toggle("Ativo", isOn: $isActive)
            }
        }
        .navigationTitle(beacon == nil ? "Novo Beacon" : "Editar Beacon")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    save()
                }
                .disabled(id.trimmingCharacters(in: .whitespaces).isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        if let b = beacon {
            b.id = trimmedID
            b.name = name
            b.email = email.isEmpty ? nil : email
            b.phone = phone.isEmpty ? nil : phone
            b.isActive = isActive
        } else {
            let new = Beacon(id: trimmedID, name: name, email: email.isEmpty ? nil : email, phone: phone.isEmpty ? nil : phone, isActive: isActive)
            context.insert(new)
        }
        try? context.save()
        dismiss()
    }
}

#Preview("BeaconsListView Preview - Empty") {
    BeaconsListView()
        .modelContainer(for: [
            Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self
        ], inMemory: true)
}

#Preview("BeaconsListView Preview - With Items") {
    let container = try! ModelContainer(for: Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    context.insert(Beacon(id: "A001", name: "Aluno 1", email: "a@a.com", phone: "1111"))
    context.insert(Beacon(id: "A002", name: "Aluno 2", email: "b@b.com", phone: "2222"))
    return BeaconsListView()
        .modelContainer(container)
}

#Preview("BeaconFormView Preview - New") {
    BeaconFormView()
        .modelContainer(for: [
            Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self
        ], inMemory: true)
}

#Preview("BeaconFormView Preview - Edit") {
    let container = try! ModelContainer(for: Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let b = Beacon(id: "A123", name: "Editar", email: "edit@x.com", phone: "9999", isActive: true)
    context.insert(b)
    return NavigationStack {
        BeaconFormView(beacon: b)
    }
    .modelContainer(container)
}
