import SwiftUI

struct BeaconsListView: View {
    @State private var viewModel = BeaconViewModel()
    @Environment(AttendanceManager.self) private var attendanceManager
    @State private var showingAdd = false
    @State private var selectedBeacon: BeaconDTO?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.beacons.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.beacons.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.primaryColor.opacity(0.3))
                        Text("Nenhum beacon cadastrado")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Toque no botão + para adicionar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.beacons) { beacon in
                            NavigationLink {
                                BeaconFormView(beacon: beacon, viewModel: viewModel)
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(beacon.isActive ? AppTheme.accentColor : Color.gray)
                                        .frame(width: 12, height: 12)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(beacon.name)
                                            .font(.headline)
                                        Text(beacon.beaconID)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if let id = beacon.id {
                                        Toggle("", isOn: Binding(
                                            get: { beacon.isActive },
                                            set: { newValue in
                                                Task {
                                                    try? await viewModel.updateBeacon(id: id, isActive: newValue)
                                                }
                                            }
                                        ))
                                        .toggleStyle(.switch)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        ErrorCard(message: error)
                            .padding()
                    }
                }
            }
            .navigationTitle("Beacons")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    BeaconFormView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadBeacons()
            }
            .refreshable {
                await viewModel.loadBeacons()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        Task {
            for idx in offsets {
                if let id = viewModel.beacons[idx].id {
                    try? await viewModel.deleteBeacon(id: id)
                }
            }
        }
    }
}

struct BeaconFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AttendanceManager.self) private var attendanceManager
    @State var beaconID: String = ""
    @State var name: String = ""
    @State var isActive: Bool = true
    @State var isSaving = false
    
    var beacon: BeaconDTO?
    var viewModel: BeaconViewModel

    init(beacon: BeaconDTO? = nil, viewModel: BeaconViewModel) {
        self.beacon = beacon
        self.viewModel = viewModel
        if let b = beacon {
            _beaconID = State(initialValue: b.beaconID)
            _name = State(initialValue: b.name)
            _isActive = State(initialValue: b.isActive)
        }
    }

    var body: some View {
        Form {
            Section("Identificação") {
                TextField("ID do Beacon (UUID)", text: $beaconID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(beacon != nil) // Não permite editar ID existente
                TextField("Nome", text: $name)
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
                    Task {
                        await save()
                    }
                }
                .disabled(isSaving || beaconID.trimmingCharacters(in: .whitespaces).isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
        let trimmedID = beaconID.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            if let b = beacon, let id = b.id {
                try await viewModel.updateBeacon(id: id, name: name, isActive: isActive)
            } else {
                try await viewModel.createBeacon(beaconID: trimmedID, name: name, isActive: isActive)
                await attendanceManager.refreshBeacons()
            }
            dismiss()
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
    }
}

#Preview("BeaconsListView - Empty") {
    BeaconsListView()
        .environment(AttendanceManager())
}

#Preview("BeaconsListView - With Beacons") {
    BeaconsListView()
        .environment(AttendanceManager())
}

#Preview("BeaconFormView - New") {
    NavigationStack {
        BeaconFormView(viewModel: BeaconViewModel())
    }
}

#Preview("BeaconFormView - Edit") {
    let beacon = BeaconDTO(
        id: UUID(),
        beaconID: "550e8400-e29b-41d4-a716-446655440000",
        name: "Beacon Aluno João",
        isActive: true
    )
    return NavigationStack {
        BeaconFormView(beacon: beacon, viewModel: BeaconViewModel())
    }
}
